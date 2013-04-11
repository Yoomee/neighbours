class AddFieldsToOffers < ActiveRecord::Migration
  
  def change
    add_column :offers, :description, :text, :after => 'user_id'
    add_column :offers, :sub_category_id, :integer, :after => 'user_id'
    add_column :offers, :category_id, :integer, :after => 'user_id'
  end
  
end
