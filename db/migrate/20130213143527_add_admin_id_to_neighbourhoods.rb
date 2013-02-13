class AddAdminIdToNeighbourhoods < ActiveRecord::Migration
  def change
    add_column :neighbourhoods, :admin_id, :integer
  end
end
