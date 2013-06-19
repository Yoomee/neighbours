class CreateSlideshows < ActiveRecord::Migration
  
  def change
    create_table :slideshows do |t|
      t.belongs_to :attachable, :polymorphic => true
      t.timestamps
    end
    add_index :slideshows, [:attachable_type, :attachable_id]
  end
  
end