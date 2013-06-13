class CreatePhotos < ActiveRecord::Migration

  def change
    create_table :photos do |t|
      t.integer :group_id
      t.integer :user_id
      t.string :image_uid
      t.timestamps
    end
    add_index :photos, :group_id
    add_index :photos, :user_id
  end

end