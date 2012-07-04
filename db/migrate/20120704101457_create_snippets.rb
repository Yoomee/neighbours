class CreateSnippets < ActiveRecord::Migration
  
  def change
    create_table :snippets do |t|
      t.string :item_type
      t.integer :item_id
      t.string :name
      t.text :text
      t.timestamps
    end
    add_index :snippets, [:item_type,:item_id]
  end
  
end