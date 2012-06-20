class Need < ActiveRecord::Base
  
  belongs_to :user
  has_many :offers
  has_one :accepted_offer, :class_name => 'Offer', :conditions => {:accepted => true}
  
  validates :user, :presence => true
  validates :title, :presence => true
  validates :description, :presence => true
  
end