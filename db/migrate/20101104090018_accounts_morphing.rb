class AccountsMorphing < ActiveRecord::Migration

  class Offer < ActiveRecord::Base
  
  end
  
  class Seat < ActiveRecord::Base
  
  end

  class Contact < ActiveRecord::Base

  end

  def self.up
    remove_column :accounts, :alpha

    duplicados = []
    originales = []

    Account.all.each do |a|

      if duplicados.include?(a)
        next
      end

      #buscamos duplicados
      @accounts = Account.find_all_by_name(a.name)
      
      #si existen
      if @accounts.length > 1
        
        #buscamos datos y ofertas,sedes, contactos de duplicados y asignamos a la cuenta original
        @accounts.slice(1, :last).each do |dup|

          @offers = Offer.find_all_by_account_id(dup.id)
          @offers.each do |o| 
            o.account_id = @accounts[0].id
            o.save!
          end
          
          @seats = Seat.find_all_by_account_id(dup.id)
          @seats.each do |s|
            s.account_id = @accounts[0].id
            s.save!
          end
          
          @contacts = Contact.find_all_by_account_id(dup.id)
          @contacts.each do |c|
            c.account_id = @accounts[0].id
            c.save!
          end
          
          duplicados << dup
        end
      end

      #correccion de errores y chapuzas
      if a.website == "http://"
        a.website = nil
      end

      a.industry_type = case a.industry_type
        when "Entertaiment" then "Entertainment"
        when "Telecomunications" then "Telecommunications"
        when "Manufactury" then "Manufacturing"
        when "" then nil
      else
        a.industry_type
      end
      
      if a.account_type == ""
        a.account_type = nil
      end

      #creamos sede virtual
      sin_sede = Seat.new();
      sin_sede.name = "(Sin Sede)"
      sin_sede.billing_address_street = "(Sin calle)"
      sin_sede.account_id = a.id
      sin_sede.save!
      
      originales << a
    end

    duplicados.each { |d| d.delete }
    originales.each { |o| o.save! }

  end

  def self.down
    add_column :accounts, :alpha, :integer
  end
end
