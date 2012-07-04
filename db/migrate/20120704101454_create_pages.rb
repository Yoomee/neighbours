class CreatePages < ActiveRecord::Migration
  
  def change
    create_table :pages do |t|
      t.integer :parent_id
      t.string :slug
      t.string :title
      t.text :text
      t.boolean :published, :default => false
      t.integer :position
      t.string :view_name, :default => "basic"
      t.string :image_uid
      t.timestamps
    end
    add_index :pages, :parent_id
  end
  
end