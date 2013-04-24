class Neighbourhood < ActiveRecord::Base
  
  validates :name, :presence => true
  validates :postcode_prefix, :uniqueness => true, :presence => true
  validates :max_radius, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }

  has_many :posts, :as => :target
  belongs_to :admin, :class_name => "User"
  has_many :users
  has_many :pages
  has_permalinks

  class << self
    
    def find_by_postcode_or_area(postcode, area=nil)
      find_by_postcode(postcode) || find_by_name(area)
    end

    def find_by_postcode(postcode)
      return nil if postcode.blank?
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

  def snippet_text(slug, default_text = nil)
    if self.try("snippet_#{slug}")
      self.try("snippet_#{slug}")
    else
      YmSnippets::Snippet.find_by_slug(slug).to_s
    end
  end

  def max_radius
    read_attribute(:max_radius) || (Neighbourhood::DEFAULT_MAX_RADIUS_IN_MILES * 1609.344).round
  end

  def max_radius_in_miles
    (max_radius.to_i / 1609.344).round(2).to_s.chomp(".0")
  end

  def pre_registrations
    PreRegistration.where("postcode LIKE ?", "#{postcode_prefix}%")
  end

  def status
    live? ? "Live" : "Coming soon"
  end
  
end

Neighbourhood::DEFAULT_MAX_RADIUS_IN_MILES = 5
