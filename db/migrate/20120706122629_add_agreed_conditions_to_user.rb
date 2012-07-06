class AddAgreedConditionsToUser < ActiveRecord::Migration
  def change
    add_column :users, :agreed_conditions, :boolean, :default => false
  end
end
