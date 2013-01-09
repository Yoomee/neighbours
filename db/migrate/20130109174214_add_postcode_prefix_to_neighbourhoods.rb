class AddPostcodePrefixToNeighbourhoods < ActiveRecord::Migration
  def change
    add_column :neighbourhoods, :postcode_prefix, :string
  end
end
