class UserMorphing < ActiveRecord::Migration
  def self.up
    rename_column :users, :email_address, :email
    add_column :users, :role, :string, :default => "Guest"
    User.reset_column_information

    roles = {
      :Admin => "Administrador",
      :Operation_manager => "Manuel Blanco",
      :Project_manager => ["Victor Pérez","Diego Marquínez","Nicolás D'Angelo","Juan Ramón Fernández"],
      :Account_manager => ["Sergio Maldonado","Javier López","Juan Manuel Elices","Alejandro"],
      :Contabilidad => ["Ángeles Barredo", "Victoria Elvira"],
      :Crm_manager => ["Marta"]
    }

    pass = "B0n1t0"

    roles.each { |rol,users|
      users.each { |u|
        user = User.find_by_name(u)
        user.role = rol.to_s
        user.password = pass
        user.password_confirmation = pass
        user.save!
      }
    }

    remove_column :users, :administrator
    remove_column :users, :permissions_resource
    remove_column :users, :permissions_offer
    remove_column :users, :permissions_license
    remove_column :users, :permissions_crm
  end

  def self.down
    rename_column :users, :email, :email_address
    remove_column :users, :role
    add_column :users, :administrator, :integer
    add_column :users, :permissions_resource, :string
    add_column :users, :permissions_offer, :string
    add_column :users, :permissions_license, :string
    add_column :users, :permissions_crm, :string
  end
end
