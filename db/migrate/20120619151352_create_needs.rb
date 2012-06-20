class CreateNeeds < ActiveRecord::Migration
  def change
    create_table :needs do |t|
      t.belongs_to :user
      t.string :title
      t.text :description
      t.date :deadline
      t.timestamps
    end
    add_index :needs, :user_id
  end
end
