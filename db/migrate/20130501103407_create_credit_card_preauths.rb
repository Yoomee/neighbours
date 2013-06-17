class CreateCreditCardPreauths < ActiveRecord::Migration

  def change
    create_table :credit_card_preauths do |t|
      t.string :name
      t.string :card_digits
      t.string :address1
      t.string :city
      t.string :zip
      t.string :address_numeric_check_result
      t.string :post_code_check_result
      t.string :cv2_check_result
      t.string :message
      t.boolean :success, :default => false
      t.timestamps
    end
  end

end