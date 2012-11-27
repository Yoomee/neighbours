class CreateAreaRadiusMaximums < ActiveRecord::Migration

  def change
    create_table :area_radius_maximums do |t|
      t.belongs_to :neighbourhood
      t.string :postcode_fragment
      t.integer :maximum_radius
      t.timestamps
      
    end
    
  add_index "area_radius_maximums", "neighbourhood_id"
  end

end
