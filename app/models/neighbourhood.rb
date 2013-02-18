class Neighbourhood < ActiveRecord::Base
  
  validates :name, :presence => true
  validates :postcode_fragment, :uniqueness => true
  has_many :posts, :as => :target
  belongs_to :admin, :class_name => "User"
  has_many :area_radius_maximums, :dependent => :destroy
  has_many :users
  
  
  accepts_nested_attributes_for :area_radius_maximums, :reject_if => :all_blank, :allow_destroy => true 

  class << self
    def find_by_postcode_or_area(postcode, area=nil)
      find_by_postcode(postcode) || find_by_name(area)
    end

    def find_by_postcode(postcode)
      neighbourhoods = where('postcode_prefix LIKE ? OR postcode_prefix = ?', "#{postcode.to_s.split.first} %", postcode.to_s.split.first)
      postcode_fragment = postcode.downcase
      while postcode_fragment.size >= postcode.split.first.size do
        matching_neighbourhoods = neighbourhoods.select { |n| n.postcode_prefix.downcase == postcode_fragment }
        if matching_neighbourhoods.present?
          return matching_neighbourhoods.first
        end
        postcode_fragment.chop!
      end
      nil
    end

  end
  
  def lat_lng
    results = Geocoder.search("#{postcode_prefix}, UK")
    geometry = results.first.data['geometry']
    [geometry['location']['lat'],geometry['location']['lng']]
  end

  def status
    live? ? "Live" : "Coming soon"
  end
    
end