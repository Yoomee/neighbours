class AddSubCategoryIdToNeeds < ActiveRecord::Migration
  def change
    add_column :needs, :sub_category_id, :integer
    add_index :needs, :sub_category_id
  end
end
