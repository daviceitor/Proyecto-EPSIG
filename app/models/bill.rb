class Bill < ActiveRecord::Base

  #RELATIONS
  belongs_to :offer

  attr_accessible :cod, :charged

  #VALIDATIONS
  validates_existence_of :offer
  validates_presence_of :cod, :on => :update

  #TRIGERS
  def before_create
    self.charged = 0
    return false if self.offer.full_billed?
  end
  
  def before_save
    if (self.charged_changed? || self.cod_changed?) && self.charged?
      self.charged_date = Date.today if self.charged_changed?
      self.system_comment
    else
      self.charged_date = nil unless self.charged
    end
  end

  protected
  def system_comment
    
    text = ""
    if self.charged && self.charged_changed?
      text += "La factura con código '#{self.cod}' pasa a cobrada"
    else
      text += "La factura con código '#{self.cod_was}' cambia de código a '#{self.cod}'" if self.charged && self.cod_changed?
    end

    self.offer.comments.create(:comment => text, :user => User.find_by_role("Admin"))
  end

end
