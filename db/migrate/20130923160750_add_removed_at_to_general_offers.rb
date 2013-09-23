class AddRemovedAtToGeneralOffers < ActiveRecord::Migration
  def change
    add_column :general_offers, :removed_at, :datetime
  end
end
