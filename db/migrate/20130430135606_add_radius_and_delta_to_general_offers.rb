class AddRadiusAndDeltaToGeneralOffers < ActiveRecord::Migration
  
  def up
    add_column :general_offers, :radius, :integer, :after => :description, :default => 0
    add_column :general_offers, :delta, :boolean, :default => true, :null => false
    GeneralOffer.reset_column_information
    GeneralOffer.update_all(:radius => GeneralOffer.default_radius)
  end
  
  def down
    remove_column :general_offers, :radius
    remove_column :general_offers, :delta
  end
  
end
