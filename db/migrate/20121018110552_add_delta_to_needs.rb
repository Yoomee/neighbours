class AddDeltaToNeeds < ActiveRecord::Migration
  def change
    add_column :needs, :delta, :boolean, :default => true, :null => false 
  end
end
