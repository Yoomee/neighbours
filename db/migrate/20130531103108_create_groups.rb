class CreateGroups < ActiveRecord::Migration
  
  def change
    create_table :groups do |t|
      t.belongs_to :user
      t.string :name
      t.text :description
      t.string :image_uid
      t.boolean :private, :default => false
      t.timestamps
    end
    add_index :groups, :user_id
  end
  
end