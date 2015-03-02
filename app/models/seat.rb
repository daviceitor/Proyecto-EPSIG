class Seat < ActiveRecord::Base
   
  define_index do
    indexes :name, :sortable => true
  end

  serialize :contact_means

  def after_initialize
    self.contact_means = {} unless self.contact_means
  end

  #ASSOCIATIONS
  belongs_to :account
  has_many :contacts

  #VALIDATIONS
  validates_presence_of :name
  validates_presence_of :street
  validates_existence_of :account

  #TRIGGERS
  after_save :reindex
  after_destroy :reindex

  #METHODS
  def create_contacts_hash(method, value)
    contact_means = {}
    method.zip(value).each do |m,v|
      if m != ""
        contact_means[m] = v
      end
    end
  end

  def reindex
    File.open("#{RAILS_ROOT}/config/need_reindex", 'w') {|f| f.write("reindex") }
  end

end
