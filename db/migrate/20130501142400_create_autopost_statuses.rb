class CreateAutopostStatuses < ActiveRecord::Migration
  def change
    create_table :autopost_statuses do |t|
      t.belongs_to :autopostable, :polymorphic => true
      t.string :provider
      t.string :status
      t.timestamps
    end
    add_index :autopost_statuses, [:autopostable_type, :autopostable_id]
    add_index :autopost_statuses, :provider
    add_index :autopost_statuses, :status
  end
end
