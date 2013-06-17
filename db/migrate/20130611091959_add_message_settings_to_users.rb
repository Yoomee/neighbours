class AddMessageSettingsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :no_private_messaging, :boolean, :default => false
    add_column :users, :email_for_new_message, :boolean, :default => true
  end
end
