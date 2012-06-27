class RemoveTextFromOffers < ActiveRecord::Migration
  
  def self.up
    remove_column :offers, :text
  end

  def self.down
    add_column :offers, :text, :text
  end
  
end
