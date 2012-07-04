class AddUserIdToPages < ActiveRecord::Migration
  
  def change
    add_column :pages, :user_id, :integer, :after => :published
    add_index :pages, :user_id
  end
  
end