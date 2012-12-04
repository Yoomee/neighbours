class AddParentIdToNeedCategories < ActiveRecord::Migration
  def change
    add_column :need_categories, :parent_id, :integer, :after => :id
    add_index :need_categories, :parent_id
  end
end
