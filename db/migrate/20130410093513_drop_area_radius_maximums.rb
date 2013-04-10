require "./db/migrate/20121018134741_create_area_radius_maximums.rb"
class DropAreaRadiusMaximums < ActiveRecord::Migration
  
  def up
    drop_table :area_radius_maximums
  end

  def down
    CreateAreaRadiusMaximums.new.migrate(:up)
  end
  
end