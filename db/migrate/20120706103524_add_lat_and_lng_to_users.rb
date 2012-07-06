class AddLatAndLngToUsers < ActiveRecord::Migration
  def change
    add_column :users, :lng, :float, :after => :postcode
    add_column :users, :lat, :float, :after => :postcode
  end
end
