class UpdateUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :creator_id, :integer
    add_column :users, :updater_id, :integer
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :active, :boolean, :default => true
    change_column :users, :crypted_password, :string, :null => true
    change_column :users, :password_salt, :string, :null => true
    remove_column :users, :login
  end

  def self.down
    add_column :users, :login, :string
    change_column :users, :crypted_password, :string, :null => false
    change_column :users, :password_salt, :string, :null => false
    remove_column :users, :active
    remove_column :users, :last_name
    remove_column :users, :first_name
    remove_column :users, :updater_id
    remove_column :users, :creator_id
  end
end
