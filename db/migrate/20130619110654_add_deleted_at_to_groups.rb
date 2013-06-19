class AddDeletedAtToGroups < ActiveRecord::Migration
  
  def change
    add_column :groups, :deleted_at, :datetime
  end
  
end