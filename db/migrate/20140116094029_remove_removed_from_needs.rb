class RemoveRemovedFromNeeds < ActiveRecord::Migration
  def up
    remove_column :needs, :removed
  end

  def down
    add_column :needs, :removed, :boolean, :default => false
  end
end
