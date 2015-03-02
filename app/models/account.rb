class Account < ActiveRecord::Base

  include Amatch

  define_index do
    indexes :name, :sortable => true
  end

  cattr_reader :industry_types
  cattr_reader :account_types
  cattr_reader :per_page
  @@per_page = 20

  @@industry_types = [ "Banking", "Communications", "Consulting", "Energy", "Entertainment", "Finance", "Government", "Healthcare",
    "Hospitality", "Insurance", "Manufacturing", "Not For Profit", "Other", "Recreation", "Retail", "Technology", "Telecommunications",
    "Transportation", "Utilities"]

  @@account_types = ["Competitor", "Customer", "Other", "Partner", "Prospect", "Provider"]

  #ASSOCIATIONS
  has_many :seats
  has_many :contacts, :through => :seats

  #VALIDATIONS
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_inclusion_of :industry_type, :in => @@industry_types, :allow_nil => true
  validates_inclusion_of :account_type, :in => @@account_types, :allow_nil => true

  def after_create
    sin_sede = Seat.new();
    sin_sede.name = "(Sin Sede)"
    sin_sede.street = "(Sin calle)"
    sin_sede.account_id = self.id
    sin_sede.save!
  end

  after_save :reindex
  after_destroy :reindex

  def self.similars name

    similar_accounts = Account.all.sort_by {|a| a.name.downcase.levenshtein_similar(name.downcase) }
    similar_accounts.select { |a|
      ((a.name.downcase.levenshtein_similar(name.downcase) > 0.5) ||
       ((LongestSubstring.new(name.downcase).match(a.name.downcase) / a.name.length.to_f) > 0.9) ||
       ((LongestSubstring.new(a.name.downcase).match(name.downcase) / name.length.to_f) > 0.9)
      )
    }
    similar_accounts.reverse.values_at(0..4)
  end

  def reindex
    File.open("#{RAILS_ROOT}/config/need_reindex", 'w') {|f| f.write("reindex") }
  end

end