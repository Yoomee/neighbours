class AddLocationFieldsToGroups < ActiveRecord::Migration
  
  def change
    add_column :groups, :lng, :float, :after => :private
    add_column :groups, :lat, :float, :after => :private
    add_column :groups, :location, :string, :after => :private
  end
  
end