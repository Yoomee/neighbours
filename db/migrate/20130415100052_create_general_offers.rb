class CreateGeneralOffers < ActiveRecord::Migration

  def change
    create_table :general_offers do |t|
      t.integer :user_id
      t.integer :sub_category_id
      t.integer :category_id
      t.text :description
      t.timestamps
    end
  end

end