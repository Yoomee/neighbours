class AddGenderToUsers < ActiveRecord::Migration
  def change
    add_column :users, :gender, :string, :default => 'unknown'
  end
end
