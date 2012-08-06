class AddRequestedValidationByCreditCardToUsers < ActiveRecord::Migration
  def change
    add_column :users, :requested_validation_by_credit_card, :boolean, :default => false, :after => :validate_by
  end
end
