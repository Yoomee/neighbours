class CreateNotifications < ActiveRecord::Migration
  
  def change
    create_table :notifications do |t|
      t.belongs_to :user
      t.belongs_to :resource, :polymorphic => true
      t.string :context
      t.boolean :read, :default => false
      t.timestamps
    end
    add_index :notifications, [:resource_id, :resource_type]
  end
  
end