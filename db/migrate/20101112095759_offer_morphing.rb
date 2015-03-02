class OfferMorphing < ActiveRecord::Migration

  class Offer < ActiveRecord::Base
  end

  class User < ActiveRecord::Base
  end

  class OfferType < ActiveRecord::Base
  end

  class Version < ActiveRecord::Base
  end

  class Bill < ActiveRecord::Base
  end

  def self.up

    drop_table :audits

    #create offer_types table
    create_table :offer_types do |t|
      t.string :name
      t.timestamps
    end

    #create versions table
    create_table :versions do |t|
      t.integer   :cod
      t.integer   :licences_amount
      t.integer   :recurrent_services_amount
      t.integer   :no_recurrent_services_amount
      t.integer   :offer_id
      t.string    :description
      t.string    :doc_file_name
      t.string    :doc_content_type
      t.integer   :doc_file_size
      t.datetime  :doc_updated_at
      t.timestamps
    end

    #create bills table
    create_table :bills do |t|
      t.string :cod
      t.boolean :charged
      t.date :charged_date
      t.integer :offer_id
      t.timestamps
    end

    offer_types = ["WebTrends","Google","Adobe/Omniture","- No Aplica -", "Yahoo", "AT Internet", "Unica", "NedStat Sitestat"]
    offer_types.each do |ot|
      OfferType.create!(:name => ot)
    end

    add_column :offers, :win_probability, :integer
    add_column :offers, :estimated_date_resolution, :date
    add_column :offers, :intermediary_id, :integer
    add_column :offers, :actual_version_index, :integer
    add_column :offers, :responsable_id, :integer
    add_column :offers, :offer_type_id, :integer
    add_column :offers, :approved_doc_file_name, :string
    add_column :offers, :approved_doc_content_type, :integer
    add_column :offers, :approved_doc_file_size, :integer
    add_column :offers, :approved_doc_updated_at, :datetime

        
    offers = Offer.all
    #first loop changes the offers id
    offers.each do |o|
      if !o.name.include? '_'
        sql = "UPDATE offers SET id=#{o.name.to_i} WHERE id=#{o.id}"
        ActiveRecord::Base.connection.execute(sql)
      end
    end

    sql = "UPDATE offers SET billing_code=NULL WHERE billing_code='NULL' or billing_code=''"
    ActiveRecord::Base.connection.execute(sql)
    sql = "UPDATE offers SET order_code=NULL WHERE order_code='NULL' or order_code=''"
    ActiveRecord::Base.connection.execute(sql)

    offers = Offer.find(:all, :order =>  "name asc")
    #second loop changes the offers data
    offers.each do |o|

      if o.offer_state == "Ganada" and (o.billed? or (o.billing_code? and o.billing_code.include? '/'))

        if o.billing_code?
          bills = o.billing_code.split(/[\/-]/)

        else
          bills = [nil]
        end

        bills.each do |bill_code|
          b = Bill.new
          b.cod = bill_code
          
          if o.name.include? '_'
            id = o.name.split('_')[0]
            b.offer_id = id
            offer = Offer.find_by_id(id)
            offer.order_code = o.order_code
            offer.billed = o.billed
            offer.save!
          else
            b.offer_id = o.id            
          end
        
          b.charged = o.charged
          b.save!
        end

      end

      if !o.name.include? '_'
        #changing offer data        
        commercial = User.find_by_name(o.commercial)
        o.commercial = commercial.id

        offer_type_name = ""
        offer_types.each do |ot|
          if o.offer_type.include?(ot)
            offer_type_name = ot
            break
          else
            if o.offer_type.include?("SiteCatalyst")
              offer_type_name ="Adobe/Omniture"
            else
              offer_type_name ="- No Aplica -"
            end
          end          
        end

        offer_type = OfferType.find_by_name(offer_type_name)
        o.offer_type_id = offer_type.id
        o.save!
       
        #insert initial version
        v = Version.new
        v.cod = 1
        v.doc_file_name = o.file_file_name
        v.doc_content_type = o.file_content_type
        v.doc_file_size = o.file_file_size
        v.doc_updated_at = o.file_updated_at
        v.offer_id = o.id
        v.description = o.description
        v.created_at = o.create_day.to_datetime
        v.save!
        o.actual_version_index = v.cod-1
        o.save!
      else
        v = Version.new
        hierarchy = o.name.split('_')
        v.cod = hierarchy[1].to_i + 1
        v.doc_file_name = o.file_file_name
        v.doc_content_type = o.file_content_type
        v.doc_file_size = o.file_file_size
        v.offer_id = hierarchy[0]
        v.description = o.description
        v.created_at = o.create_day.to_datetime
        v.save!
                
        offer = Offer.find_by_id(hierarchy[0])
        if offer.offer_state != "Ganada"
          offer.offer_state = o.offer_state
          offer.order_code = o.order_code unless offer.order_code
          offer.actual_version_index = v.cod-1
          offer.save!
        end
                
        o.delete
      end
    end

    last_offer = Offer.find(:last)

    sql = "ALTER TABLE offers AUTO_INCREMENT = #{last_offer.id}"
    ActiveRecord::Base.connection.execute(sql)

    o = Offer.find(1531)
    o.actual_version_index = 6
    o.save!

    o = Offer.find(1467)
    o.actual_version_index = 1
    o.save!

    rename_column :offers, :commercial, :commercial_id
    rename_column :offers, :create_day, :creation_day
    rename_column :offers, :offer_state, :state
    rename_column :offers, :billed, :full_billed
    rename_column :offers, :order_code, :order_cod

    remove_column :offers, :offer_type
    remove_column :offers, :description
    remove_column :offers, :file_file_name
    remove_column :offers, :file_content_type
    remove_column :offers, :file_file_size
    remove_column :offers, :file_updated_at
    remove_column :offers, :name
    remove_column :offers, :billing_code
    remove_column :offers, :offer_p
    remove_column :offers, :charged
    
  end

  def self.down
    drop_table :offer_types
    drop_table :bills
    drop_table :versions
    remove_column :offers, :win_probability
    remove_column :offers, :estimated_date_resolution
    remove_column :offers, :intermediary_id
    remove_column :offers, :actual_version_index
    remove_column :offers, :responsable_id
    remove_column :offers, :approved_doc_file_name
    remove_column :offers, :approved_doc_content_type
    remove_column :offers, :approved_doc_file_size
    remove_column :offers, :approved_doc_updated_at

    rename_column :offers, :commercial_id, :commercial
    rename_column :offers, :creation_day, :create_day
    rename_column :offers, :offer_type_id, :offer_type
    rename_column :offers, :state, :offer_state
    rename_column :offers, :full_billed, :charged
    rename_column :offers, :order_cod, :order_code

    add_column :offers, :file_file_name, :string
    add_column :offers, :file_content_type, :string
    add_column :offers, :file_file_size, :integer
    add_column :offers, :file_updated_at, :date
    add_column :offers, :name, :string
    add_column :offers, :billing_code, :string
    add_column :offers, :offer_p, :string
    add_column :offers, :billed, :boolean

  end
end
