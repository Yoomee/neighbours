class PreRegistration < ActiveRecord::Base
    include YmCore::Model
    validates :name, :email, :postcode, :presence => true
    validates :email, :email => true
    validates :postcode, :postcode => true
    
    before_save :geocode
    
    scope :with_lat_lng, where("lat IS NOT NULL AND lng IS NOT NULL")
    
    class << self
      
      def name_of_town(postcode)
        results = Geocoder.search("#{postcode}, UK")
        address_components = results.first.data['address_components']
        town_component = address_components.select{|component| component['types'].include?('postal_town')}.first
        town_component.try(:[],'short_name')        
      end
      
      def convert_all_to_users
        existing_user_emails = User.where('email IN (?)', PreRegistration.all.collect(&:email)).collect(&:email)
        where('email NOT IN (?)', existing_user_emails).each(&:convert_to_user!)
      end
      
    end
    
    def convert_to_user!
      return true if User.exists?(:email => email)
      User.create(
        :role => 'pre_registration',
        :full_name => name,
        :email => email,
        :postcode => postcode,
        :city => area,
        :lat => lat,
        :lng => lng
      )
    end
    
    def city
      return nil if postcode.nil?
      @city ||= PreRegistration.name_of_town(postcode)
    end
    
    def coming_soon?
      neighbourhood && !neighbourhood.live?
    end
    
    def neighbourhood
      Neighbourhood.find_by_postcode_or_area(postcode, area)
    end
    
    def live?
      neighbourhood && neighbourhood.live?
    end

    def postcode_with_uk
      "#{postcode}, UK"
    end
    
    def build_user
      attrs = attributes.symbolize_keys.slice(:email, :postcode)
      attrs.merge!(:email_confirmation => email, :full_name => name, :city => city, :neighbourhood => neighbourhood)
      User.new(attrs)
    end
    
    def lat_lng
      lat.present? && lng.present? ? [lat,lng] : nil
    end
    
    private
    def geocode
      results = Geocoder.search(postcode_with_uk)
      geometry = results.first.data['geometry']
      self.lat = geometry['location']['lat']
      self.lng = geometry['location']['lng']
      
      if neighbourhood
        self.area = neighbourhood.name
      else
        address_components = results.first.data['address_components']
        town_component = address_components.select{|component| component['types'].include?('postal_town')}.first
        self.area = town_component.try(:[],'short_name')
      end
    end
    
end
