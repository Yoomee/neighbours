class AddGeneralOfferIdToOffers < ActiveRecord::Migration
  
  def change
    add_column :offers, :general_offer_id, :integer
  end
  
end
