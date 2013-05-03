class RemoveCardFieldsFromUser < ActiveRecord::Migration
  
  def up
    remove_column :users, :card_type
    remove_column :users, :card_digits
    remove_column :users, :card_expiry_date
  end

  def down
    add_column :users, :card_type, :string
    add_column :users, :card_digits, :integer
    add_column :users, :card_expiry_date, :string    
  end
  
end
