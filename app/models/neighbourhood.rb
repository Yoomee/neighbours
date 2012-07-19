class Neighbourhood < ActiveRecord::Base
  
  validates :name, :presence => true
  has_many :posts, :as => :target
  
end