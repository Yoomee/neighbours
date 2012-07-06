class CreateFlags < ActiveRecord::Migration

  def change
    create_table :flags do |t|
      t.belongs_to :user
      t.belongs_to :resource, :polymorphic => true
      t.text :text
      t.datetime :resolved_at
      t.timestamps
    end
  end

end
