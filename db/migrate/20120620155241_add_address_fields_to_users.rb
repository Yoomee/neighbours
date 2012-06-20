class AddAddressFieldsToUsers < ActiveRecord::Migration

  def change
    add_column :users, :address1, :string
    add_column :users, :city, :string
    add_column :users, :county, :string
    add_column :users, :postcode, :string
    add_column :users, :phone, :string
  end

end
