class CreateMessageThreadUsers < ActiveRecord::Migration
  def change
    create_table :message_thread_users do |t|
      t.references :message_thread
      t.integer :user_id
      t.datetime :read_at
      t.boolean :read, :default => false

      t.timestamps
    end
    add_index :message_thread_users, :message_thread_id
    add_index :message_thread_users, :user_id
  end
end
