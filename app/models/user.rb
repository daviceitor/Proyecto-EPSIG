require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include Roleful

  cattr_reader :per_page
  @@per_page = 20
  
  #RELATIONS
  has_many :resources
  
  validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email,    :on => :create
  validates_format_of       :email,    :with => Authentication.email_regex, :message => "tiene un formato incorrecto"

  
  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :name, :password, :password_confirmation, :role


  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(email, password)
    return nil if email.blank? || password.blank?
    u = find_by_email(email.downcase) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def name=(value)
    write_attribute :name, (value ? value : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  def self.random_password( len = 20 )
    chars = (("a".."z").to_a + ("1".."9").to_a )- %w(i o 0 1 l 0)
    newpass = Array.new(len, '').collect{chars[rand(chars.size)]}.join
  end 

  #ROLES Admin, Guest, Operation_manager, Account_manager, Project_manager, Contabilidad, Crm_reader, Crm_manager
  role :Admin, :superuser => true 
  role :Guest
  role :Crm_reader
  
  #CRM PERMISES

  role :Crm_manager,:Account_manager,:Operation_manager,:Project_manager do
    can :manage_crm
  end

  #OFFER PERMISES

  role :Project_manager do
    can :view_offer do |offer|
      self.id == offer.responsable_id
    end
    can :index_offers do
      !Offer.find_by_responsable_id(self.id).nil?
    end
    can :download_version do |version|
      self.can_view_offer? version.offer
    end
  end

  role :Operation_manager do
    can :edit_offer
    can :delete_offer
    can :create_version
    can :edit_version
    can :delete_version
    can :assign_responsable
  end

  role :Account_manager do
    can :edit_offer do |offer|
      self.id == offer.commercial_id.to_i
    end

    can :create_version do |offer|
      self.id == offer.commercial_id.to_i
    end

    can :edit_version do |version|
      self.id == version.offer.commercial_id.to_i
    end

    can :delete_offer do |offer|
      self.id == offer.commercial_id.to_i
    end

    can :delete_version do |version|
      self.id == version.offer.commercial_id.to_i
    end

  end

  role :Account_manager,:Operation_manager,:Contabilidad do
    can :view_offer
    can :index_offers
    can :index_all_offers
    can :download_version
  end

  role :Contabilidad do
    can :edit_offer_bills_data
  end

  role :Account_manager,:Operation_manager do
    can :create_offer
  end
  
  #BILLS PERMISES

  role :Contabilidad do
    can :manage_bills
  end 

  role :Account_manager,:Operation_manager,:Project_manager,:Contabilidad do
    can :view_bills
  end

  #USERS PERMISES
  role :Operation_manager do
    can :manage_users
  end

  #OPERATIONS PERMISES
  role :Operation_manager,:Project_manager do
    can :view_operations
  end

  role :Project_manager, :Contabilidad, :Account_manager do
    can :go_to_home
  end
  
  #ALL ACTIONS PERMITED

  role :all do
    can :change_pass do |user_id|
      self.id == user_id.to_i
    end

    can :view_crm

    can :manage_resource do |resource|
      self.id == resource.user_id 
    end

  end
  
end
