class AddRemovedToNeeds < ActiveRecord::Migration
  def change
    add_column :needs, :removed, :boolean, :default => false
  end
end
