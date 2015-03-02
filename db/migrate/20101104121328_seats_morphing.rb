class SeatsMorphing < ActiveRecord::Migration

  def self.up
    add_column :seats, :contact_means, :text
    Seat.reset_column_information
    rename_column :seats, :billing_address_street, :street
    rename_column :seats, :billing_address_city, :city
    rename_column :seats, :billing_address_country, :country
    rename_column :seats, :billing_address_state, :state
    rename_column :seats, :billing_address_postalcode, :postalcode

    Seat.all.each do |s|

      contact_means = {}

      if s.phone_office != nil && s.phone_office != ""
        contact_means["Teléfono Oficina"] = s.phone_office
      end
      if s.phone_alternate != nil && s.phone_alternate != ""
        contact_means["Teléfono Alternativo"] = s.phone_alternate
      end
      if s.phone_fax != nil && s.phone_fax != ""
        contact_means["Fax"] = s.phone_fax
      end
      if s.email1 != nil && s.email1 != ""
        contact_means["Email"] = s.email1
      end
      if s.email2 != nil && s.email2 != ""
        contact_means["Email Alternativo"] = s.email2
      end

      s.contact_means = contact_means
      s.save!
   
    end

    remove_column :seats, :email1
    remove_column :seats, :email2
    remove_column :seats, :phone_office
    remove_column :seats, :phone_fax
    remove_column :seats, :phone_alternate

  end

  def self.down

    remove_column :seats, :contact_means

    rename_column :seats, :street, :billing_address_street
    rename_column :seats, :city, :billing_address_city
    rename_column :seats, :country, :billing_address_country
    rename_column :seats, :state, :billing_address_state
    rename_column :seats, :postalcode, :billing_address_postalcode

    add_column :seats, :email1, :string
    add_column :seats, :email2, :string
    add_column :seats, :phone_office, :string
    add_column :seats, :phone_fax, :string
    add_column :seats, :phone_alternate, :string
  end
end
