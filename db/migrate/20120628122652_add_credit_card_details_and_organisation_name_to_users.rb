class AddCreditCardDetailsAndOrganisationNameToUsers < ActiveRecord::Migration
  
  def change
    add_column :users, :card_type, :string
    add_column :users, :card_digits, :integer
    add_column :users, :card_expiry_date, :string
    add_column :users, :organisation_name, :string
  end

end
