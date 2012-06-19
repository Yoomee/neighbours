class CreateOffers < ActiveRecord::Migration
  def change
    create_table :offers do |t|
      t.belongs_to :need
      t.belongs_to :user
      t.text :text
      t.boolean :accepted, :default => false
      t.timestamps
    end
    add_index :offers, :need_id
    add_index :offers, :user_id
  end
end
