class CreateSlides < ActiveRecord::Migration
  
  def change
    create_table :slides do |t|
      t.belongs_to :slideshow
      t.text :caption
      t.string :image_uid
      t.integer :position
      t.timestamps
    end
    add_index :slides, :slideshow_id
  end
  
end