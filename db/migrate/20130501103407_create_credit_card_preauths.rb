class CreateCreditCardPreauths < ActiveRecord::Migration

  def change
    create_table :credit_card_preauths do |t|
      t.belongs_to :user
      t.string :card_type
      t.string :card_digits
      t.string :house_number
      t.string :street_name
      t.string :city
      t.string :postcode
      t.string :failed_message
      t.timestamps
    end
  end

end