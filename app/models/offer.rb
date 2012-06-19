class Offer < ActiveRecord::Base
  
  belongs_to :need
  belongs_to :user
  validates :text, :presence => true
  
end