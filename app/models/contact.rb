class Contact < ActiveRecord::Base

  #ASSOCIATIONS
  belongs_to :seat

  define_index do
    indexes [contact.name, contact.sur_name], :as => :contact_name
  end

  @@lead_sources = ["Cold Call", "Existing Customer", "Partner", "Public Relations", "Self Generated", "Trade Show", "WebSite"]
  @@per_page = 30

  serialize :contact_means, Hash
  cattr_reader :lead_sources
  cattr_reader :per_page

  def after_initialize
    self.contact_means = {} unless self.contact_means
  end
  
  after_save :reindex
  after_destroy :reindex

  #VALIDATIONS
  validates_presence_of :name
  validates_inclusion_of :lead_source, :in => @@lead_sources, :allow_blank => true
  validates_existence_of :seat

  #METHODS
  def create_contacts_hash(method, value)
    self.contact_means = {}
    method.zip(value).each do |m,v|
      if m != ""
        self.contact_means[m] = v
      end
    end
  end

  def reindex
    File.open("#{RAILS_ROOT}/config/need_reindex", 'w') {|f| f.write("reindex") }
  end

  def self.similars name, surname

    similar_contacts = Contact.all.sort_by {|c| ("#{c.name.downcase} #{c.sur_name.downcase if c.sur_name}").levenshtein_similar("#{name.downcase} #{surname.downcase}") }
    similar_contacts.select { |c|
      (("#{c.name.downcase} #{c.sur_name.downcase if c.sur_name}").levenshtein_similar("#{name.downcase} #{surname.downcase}") > 0.6)
    }
    similar_contacts.reverse.values_at(0..4)
  end

end
