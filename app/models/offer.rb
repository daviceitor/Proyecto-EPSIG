class Offer < ActiveRecord::Base
  acts_as_commentable
  include AASM  

  define_index do
    indexes :id, :sortable => true
  end

  aasm_column :state

  aasm_initial_state :Pendiente

  aasm_state :Pendiente,            :after_enter => :system_comment
  aasm_state :Ganada,               :after_enter => [:system_comment,:mail_offer_win_notification]
  aasm_state :Perdida,              :after_enter => :system_comment
  aasm_state :Eliminada,            :after_enter => :system_comment
  
  aasm_event :Perdida do
    transitions :to => :Perdida, :from => [:Pendiente,:Ganada,:Eliminada]
  end

  aasm_event :Pendiente do
    transitions :to => :Pendiente, :from => [:Eliminada,:Ganada,:Perdida]
  end

  aasm_event :Ganada do
    transitions :to => :Ganada, :from => [:Pendiente,:Perdida,:Eliminada]
  end

  aasm_event :Eliminada do
    transitions :to => :Eliminada, :from => [:Pendiente,:Ganada,:Perdida]
  end
  
  @@per_page = 30
  cattr_reader :per_page
  
  #RELATIONS
  belongs_to :account
  belongs_to :intermediary, :class_name => "Account"
  belongs_to :commercial, :class_name => "User"
  belongs_to :responsable, :class_name => "User"
  belongs_to :offer_type
  has_many :versions, :order => "cod"
  has_many :bills
  has_many :notes

  has_attached_file :approved_doc,
    :path => ":rails_root/public/system/offers/:id/:normalize_name.:extension",
    :url => "/offers/:id/download"

  attr_accessible :approved_doc, :approved_doc_file_name, :approved_doc_content_type, :approved_doc_file_size, :approved_doc_updated_at
  attr_accessible :account_id, :offer_type_id, :commercial_id, :estimated_date_resolution, :description, :creation_day, :win_probability,:order_cod,:actual_version_index,:state,:responsable_id,:intermediary_id, :full_billed

  #TRIGGERS
  def before_create
    self.actual_version_index = 0
    self.full_billed = 0
    self.creation_day = Date.today
  end

  def after_create
    self.system_comment
    File.open("#{RAILS_ROOT}/config/need_reindex", 'w') {|f| f.write("reindex") }
  end

  def after_update
    self.mail_responsable_notification if(self.responsable_id_changed? && !self.responsable_id.nil?)
  end
 
  #VALIDATIONS
  validates_existence_of :commercial,:offer_type,:account
  validates_existence_of :intermediary,:responsable, :allow_nil => true
  validates_inclusion_of :state, :in => Offer.aasm_states_for_select.map{|state| state[0]}
  validates_numericality_of :win_probability, :integer_only => true, :less_than_or_equal_to => 100, :greater_than_or_equal_to => 0, :allow_nil => true
  validates_numericality_of :actual_version_index, :integer_only => true, :greater_than_or_equal_to => 0, :allow_nil => true
  validates_presence_of :win_probability, :estimated_date_resolution, :on => :create

  validate_on_update :presence_of_doc_actual_version_on_win, :presence_of_doc_aprobation_on_win
    
  #METHODS
  Paperclip.interpolates :normalize_name do |attachment, style|
    name = "#{attachment.instance.actual_version.id}_aprobacion"
  end

  def presence_of_doc_aprobation_on_win
    unless self.approved_doc? || self.state != "Ganada" || (self.state_was != "Pendiente" && self.state_was != "Perdida")
      errors.add_to_base "Debe introducir el documento de aprobación para pasar a ganada la propuesta"
    end
  end

  def presence_of_doc_actual_version_on_win
    unless (self.actual_version && self.actual_version.doc?) || self.state != "Ganada" || (self.state_was != "Pendiente" && self.state_was != "Perdida")
      errors.add_to_base "La versión actual debe tener asociada un documento"
    end
  end

  def self.filter_states  
    filter_states = []
    Offer.aasm_states.each do |s|
      if s.name != :Eliminada
        filter_states << s.display_name
      end
    end
    filter_states
  end

  def actual_version
    self.versions[self.actual_version_index]
  end

  def historial
    self.versions.reverse
  end

  def mail_offer_win_notification
    @users = User.find_all_by_role(["Operation_manager","Contabilidad"])

    @users.each do |user|
      Notifier.deliver_offer_win_notification user, self
    end
  end

  def mail_responsable_notification
    Notifier.deliver_responsable_notification self.responsable, self
  end

  def self.filter_index current_user, filter, page

    full_billed = filter["full_billed"]
    full_charged = filter["full_charged"]
    filter.delete "full_billed"
    filter.delete "full_charged"
    
    unless current_user.can_index_all_offers?
      filter["responsable_id"] = current_user.id.to_s
    end

    sql = self.generate_sql filter, full_billed, full_charged
    logger.debug sql

    Offer.paginate_by_sql(sql, :page => page, :per_page => self.per_page)
  end

  def self.generate_sql filter, full_billed, full_charged
    having_arr = filter.select{ |k,v| !v.empty?}

    sql = "SELECT o.* FROM bills b right outer join offers o on o.id = b.offer_id group by o.id,offer_id"
    sql += " HAVING state != 'Eliminada' "
    sql += full_billed_sql full_billed
    sql += full_charged_sql full_charged
    sql += " AND " unless having_arr.empty?
    sql += having_arr.map{|k,v| "#{k} = ?"}.join(" AND ")
    sql += " ORDER BY o.id DESC"

    [sql,*having_arr.map{|x| x[1]}]
  end

  def self.full_billed_sql full_billed
    billed_sql = ""    
    billed_sql = case full_billed
    when "0" then "AND offer_id is null "
    when "2" then "AND offer_id is not null and full_billed = 0 "
    when "1" then "AND offer_id is not null and full_billed = 1 "
    else ""
    end
  end

  def self.full_charged_sql full_charged
    charged_sql = ""
    charged_sql += case full_charged
    when "0" then "AND sum(charged) = 0 "
    when "2" then "AND sum(charged) < count(offer_id) and sum(charged) > 0 "
    when "1" then "AND sum(charged) = count(offer_id) "
    else ""
    end
  end

  protected
  def system_comment
    
    return if self.new_record?
    
    text = ""
    if self.state_was.nil?
      text += "Creada en estado #{self.aasm_current_state}"
    else
      text += "Pasa a estado #{self.aasm_current_state}"
    end   

    self.comments.create(:comment => text, :user => User.find_by_role("Admin"))
  end
 
end

