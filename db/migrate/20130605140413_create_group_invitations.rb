class CreateGroupInvitations < ActiveRecord::Migration
  
  def change
    create_table :group_invitations do |t|
      t.integer :group_id
      t.integer :user_id
      t.integer :inviter_id
      t.string :email
      t.string :ref
      t.timestamps
    end
    add_index :group_invitations, :group_id
    add_index :group_invitations, :user_id
  end
  
end
