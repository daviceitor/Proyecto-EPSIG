class OfferType < ActiveRecord::Base

  @@offer_types = ["WebTrends","Google","Adobe/Omniture","No Aplica"]
  cattr_reader :offer_types

  #RELATIONS
  has_many :offer

  #VALIDATIONS
  validates_presence_of :name
  validates_inclusion_of :name, :in => @@offer_types


end
