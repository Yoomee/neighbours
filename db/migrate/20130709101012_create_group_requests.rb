class CreateGroupRequests < ActiveRecord::Migration
  
  def change
    create_table :group_requests do |t|
      t.integer :group_id
      t.integer :user_id
      t.timestamps
    end
    add_index :group_requests, :group_id
    add_index :group_requests, :user_id
  end
  
end
