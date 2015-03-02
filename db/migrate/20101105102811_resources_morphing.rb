class ResourcesMorphing < ActiveRecord::Migration
  def self.up
    rename_column :link_resources, :lresource, :url
    rename_table :link_resources, :resources
    add_column :resources, :user_id, :integer
  end

  def self.down
    rename_column :resources, :url, :lresource
    rename_table :resources, :link_resources
    remove_column :resources, :user_id
  end
end
