class AddMessageToGroupInvitations < ActiveRecord::Migration
  
  def change
    add_column :group_invitations, :message, :text, :after => :ref
  end
  
end
