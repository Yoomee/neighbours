class AddSentActivationCodeAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :sent_activation_code_at, :datetime, :after => :updated_at
  end
end
