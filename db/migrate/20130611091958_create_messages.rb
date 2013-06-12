class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.text :text
      t.references :message_thread
      t.references :user

      t.timestamps
    end
    add_index :messages, :message_thread_id
    add_index :messages, :user_id
  end
end
