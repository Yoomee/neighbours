class Neighbourhood < ActiveRecord::Base
  
  validates :name, :presence => true
  has_many :posts, :as => :target
  has_many :area_radius_maximums, :dependent => :destroy
  
  accepts_nested_attributes_for :area_radius_maximums, :reject_if => :all_blank, :allow_destroy => true 
    
end