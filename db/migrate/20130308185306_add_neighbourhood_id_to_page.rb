class AddNeighbourhoodIdToPage < ActiveRecord::Migration
  def change
    add_column :pages, :neighbourhood_id, :integer
    add_index :pages, :neighbourhood_id
  end
end
