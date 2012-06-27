class CreatePosts < ActiveRecord::Migration
  
  def change
    create_table :posts do |t|
      t.belongs_to :user
      t.belongs_to :target, :polymorphic => true      
      t.text :text
      t.string :image_uid
      t.string :video_url
      t.string :video_title
      t.text :video_description
      t.timestamps
    end
    add_index :posts, [:target_id, :target_type]
  end
  
end