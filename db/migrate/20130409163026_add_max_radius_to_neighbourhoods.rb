class AddMaxRadiusToNeighbourhoods < ActiveRecord::Migration
  def change
    add_column :neighbourhoods, :max_radius, :integer
  end
end