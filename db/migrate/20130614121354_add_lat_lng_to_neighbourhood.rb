class AddLatLngToNeighbourhood < ActiveRecord::Migration
  
  def change
    add_column :neighbourhoods, :lng, :float, :after => :postcode_prefix
    add_column :neighbourhoods, :lat, :float, :after => :postcode_prefix
  end
  
end