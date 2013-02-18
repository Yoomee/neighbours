class AddNeighbourhoodToUser < ActiveRecord::Migration
  def change
    add_column :users, :neighbourhood_id, :integer
    add_index :users, :neighbourhood_id
    User.reset_column_information
    User.find_each(&:save)
  end
end
