class ContactsMorphing < ActiveRecord::Migration

  class Seat < ActiveRecord::Base
    
  end

  def self.up
    add_column :contacts, :contact_means, :text
    remove_column :contacts, :alpha

    Contact.all.each do |c|
    
      contact_means = {}

      sin_sede = Seat.find_by_account_id(c.account_id, :conditions => { :name => "(Sin Sede)" })

      if c.seat_id == nil && c.account_id != nil || Seat.find_by_id(c.seat_id).nil?
        if !sin_sede.nil?
          c.seat_id = sin_sede.id
        end
      end

      c.lead_source = case c.lead_source
        when "ColdCall" then "Cold Call"
        when "ExistingCustomer" then "Existing Customer"
        when "Web Site" then "WebSite"
        when "" then nil
      else
        c.lead_source
      end

      if c.phone_mobile != nil && c.phone_mobile != ""
        contact_means["Teléfono Movil"] = c.phone_mobile
      end
      if c.phone_other != nil && c.phone_other != ""
        contact_means["Teléfono Alternativo"] = c.phone_other
      end
      if c.email_address != nil && c.email_address != ""
        contact_means["Email"] = c.email_address
      end
      if c.email_other != nil && c.email_other != ""
        contact_means["Email Alternativo"] = c.email_other
      end
      unless c.valid?
        debugger
      end
      c.contact_means = contact_means
      c.save!
    end

    remove_column :contacts, :email_address
    remove_column :contacts, :phone_mobile
    remove_column :contacts, :phone_other
    remove_column :contacts, :email_other
    #remove_column :contacts, :account_id

  end

  def self.down
    remove_column :contacts, :contact_means
    add_column :contacts, :alpha, :string
    add_column :contacts, :email_address, :string
    add_column :contacts, :phone_mobile, :string
    add_column :contacts, :phone_other, :string
    add_column :contacts, :email_other, :string
  end
end
