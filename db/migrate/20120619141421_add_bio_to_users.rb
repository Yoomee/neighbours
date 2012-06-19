class AddBioToUsers < ActiveRecord::Migration
  
  def change
    add_column :users, :bio, :text, :after => :last_name
  end
  
end