class ChangesInvolvingRemovedAt < ActiveRecord::Migration
  def up
    add_column :offers, :removed_at, :datetime, :after => :updated_at
    add_column :flags, :removed_at, :datetime, :after => :updated_at
    add_column :group_invitations, :removed_at, :datetime, :after => :updated_at    
    add_column :needs, :removed_at, :datetime, :after => :updated_at
    add_column :posts, :removed_at, :datetime, :after => :updated_at
  end

  def down
    remove_column :offers, :removed_at
    remove_column :flags, :removed_at
    remove_column :group_invitations, :removed_at    
    remove_column :needs, :removed_at
    remove_column :posts, :removed_at
  end
end
