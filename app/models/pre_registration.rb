class PreRegistration < ActiveRecord::Base
    include YmCore::Model
    validates :name, :email, :postcode, :presence => true
    validates :email, :email => true
    validates :postcode, :postcode => true
    
    before_validation :insert_space_into_postcode_if_needed
    before_save :geocode
    
    scope :with_lat_lng, where("lat IS NOT NULL AND lng IS NOT NULL")
    
    class << self
      
      def name_of_town(postcode)
        results = Geocoder.search("#{postcode}, UK")
        address_components = results.first.data['address_components']
        town_component = address_components.select{|component| component['types'].include?('postal_town')}.first
        town_component.try(:[],'short_name')        
      end
      
      def create_users
        existing_user_emails = User.where('email IN (?)', PreRegistration.all.collect(&:email)).collect(&:email)
        where('email NOT IN (?)', existing_user_emails).each(&:create_user)
      end
      
    end
    
    def create_user
      return true if User.exists?(:email => email)
      user = User.new(
        :role => 'pre_registration',
        :full_name => name,
        :email => email,
        :postcode => postcode,
        :city => area,
        :lat => lat,
        :lng => lng
      )
      user.last_name ||= '_BLANK_'
      user.save
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
    
    def insert_space_into_postcode_if_needed
      if postcode.present? && postcode.strip.split.size == 1
        (postcode.strip.length - 1).times do |num|
          postcode_with_space = postcode.dup.insert(num + 1, ' ')
          if postcode_with_space.upcase =~ PostcodeValidator::POSTCODE_FORMAT
            self.postcode = postcode_with_space
            break
          end
        end
      end
    end
    
end
