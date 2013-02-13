class Neighbourhood < ActiveRecord::Base
  
  validates :name, :presence => true
  has_many :posts, :as => :target
  belongs_to :admin, :class_name => "User"
  has_many :area_radius_maximums, :dependent => :destroy
  
  accepts_nested_attributes_for :area_radius_maximums, :reject_if => :all_blank, :allow_destroy => true 
  
  def status
    if live then
      "Live"
    else
      "Coming soon"
    end
  end
  
  def lat_lng
    results = Geocoder.search("#{postcode_prefix}, UK")
    geometry = results.first.data['geometry']
    [geometry['location']['lat'],geometry['location']['lng']]
  end
    
end