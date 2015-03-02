class Version < ActiveRecord::Base

  #RELATIONS
  belongs_to :offer
  acts_as_list :scope => :offer, :column => :cod

  has_attached_file :doc,
   :path => ":rails_root/public/system/offers/:offer_folder/:id.:extension",
   :url => "/versions/:id/download"

  attr_accessible :doc, :doc_file_name, :doc_content_type, :doc_file_size, :doc_updated_at
  attr_accessible :cod, :description, :licences_amount, :recurrent_services_amount, :no_recurrent_services_amount, :offer_id

  #TRIGGERS
  def before_save
    self.licences_amount = nil unless self.licences_amount
    self.recurrent_services_amount = nil unless self.recurrent_services_amount
    self.no_recurrent_services_amount = nil unless self.no_recurrent_services_amount
  end

  def after_create
    self.offer.actual_version_index = self.cod-1
    self.offer.save!
  end

  #VALIDATIONS
  validates_numericality_of :licences_amount, :greater_than_or_equal_to => 0, :allow_nil => true
  validates_numericality_of :recurrent_services_amount, :greater_than_or_equal_to => 0, :allow_nil => true
  validates_numericality_of :no_recurrent_services_amount, :greater_than_or_equal_to => 0, :allow_nil => true
  validates_existence_of :offer, :allow_nil => true

  validate :at_least_one_checkbox_was_ticked

  #METHODS
  Paperclip.interpolates :offer_folder do |attachment, style|
    attachment.instance.offer_id
  end

  def at_least_one_checkbox_was_ticked
    unless self.licences_amount || self.no_recurrent_services_amount || self.recurrent_services_amount || !self.doc?
      errors.add_to_base "Como mínimo debe estar marcado uno de los siguientes campos Licencias, Servicios recurrentes, Servicios no recurrentes"
    end
  end

  def version_cod
    version_cod = self.offer_id.to_s
    version_cod += "_#{self.cod.to_i-1}" if self.cod > 1
    version_cod
  end

end
