class Neighbourhood < ActiveRecord::Base
  include YmCore::Model

  has_many :posts, :as => :target
  belongs_to :admin, :class_name => "User"
  has_many :users
  has_many :pages
  has_permalinks
  has_many :offers, :through => :users
  has_many :needs, :through => :users

  geocoded_by :postcode_with_country, :latitude => :lat, :longitude => :lng
  
  validates :name, :presence => true
  validates :postcode_prefix, :uniqueness => true, :presence => true
  validates :max_radius, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }

  after_validation :geocode, :if => :postcode_prefix_changed?
  after_save :find_users
  before_destroy :find_new_neighbourhood_for_users

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
    [lat, lng]
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

  def postcode_with_country
    "#{postcode_prefix}, UK"
  end

  def status
    live? ? "Live" : "Coming soon"
  end
  
  def welcome_email_text
    Neighbourhood::WELCOME_EMAIL_TEXT.sub('[NAME]', name)
  end
  
  private
  def find_new_neighbourhood_for_users
    users.each do |user|
      user.neighbourhood = Neighbourhood.without(self).find_by_postcode_or_area(user.postcode)
      user.save
    end
  end
  
  def find_users
    User.where(:neighbourhood_id => nil).where("postcode LIKE ?", "#{postcode_prefix}%").update_all(:neighbourhood_id => id)
  end

end

Neighbourhood::DEFAULT_MAX_RADIUS_IN_MILES = 5
Neighbourhood::WELCOME_EMAIL_TEXT = <<-TEXT
We have launched in [NAME]!

You can now offer and receive help from your neighbours. Use the link below to finish registration and become a full member:

<REGISTER_URL>

Thanks,

The #{Settings.site_name} team
#{Settings.site_url}
TEXT