class RemoveUnconfirmedEmailFromUsers < ActiveRecord::Migration
  
  def up
    remove_column :users, :unconfirmed_email
  end

  def down
    add_column :users, :unconfirmed_email, :string
  end
  
end
