class AddDeltaToGroups < ActiveRecord::Migration
  
  def change
    add_column :groups, :delta, :boolean, :default => true
  end
  
end