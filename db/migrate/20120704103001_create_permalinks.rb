class CreatePermalinks < ActiveRecord::Migration
  
  def change
    create_table :permalinks do |t|
      t.string :path
      t.belongs_to :resource, :polymorphic => true
      t.boolean :active, :default => true
      t.timestamps
    end
    add_index :permalinks, :path
  end
  
end
