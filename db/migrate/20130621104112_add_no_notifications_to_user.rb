class AddNoNotificationsToUser < ActiveRecord::Migration
  def change
    add_column :users, :no_notifications, :boolean, :default => false
  end
end
