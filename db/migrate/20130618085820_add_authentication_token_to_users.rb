class AddAuthenticationTokenToUsers < ActiveRecord::Migration
  
  def change
    add_column :users, :authentication_token, :string, :after => :last_sign_in_ip
  end
  
end