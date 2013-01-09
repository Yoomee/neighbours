class AddLiveFlagToNeighbourhoods < ActiveRecord::Migration
  def change
    add_column :neighbourhoods, :live, :boolean
  end
end
