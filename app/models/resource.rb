class Resource < ActiveRecord::Base

  define_index do
    indexes :name, :sortable => true
  end

  belongs_to :user

  @@per_page = 30
  cattr_reader :per_page

  #VALIDATIONS
  validates_presence_of :name
  validates_presence_of :url

  #TRIGGERS
  after_save :reindex
  after_destroy :reindex

  def reindex
    File.open("#{RAILS_ROOT}/config/need_reindex", 'w') {|f| f.write("reindex") }
  end

end
