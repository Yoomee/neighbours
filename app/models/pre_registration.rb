class PreRegistration < ActiveRecord::Base
    include YmCore::Model
    validates :name, :email, :postcode, :presence => true
    validates :email, :email => true
    validates :postcode, :postcode => true
    
    before_save :geocode
    
    def coming_soon?
      neighbourhood && !neighbourhood.live?
    end
    
    def neighbourhood
      Neighbourhood.find_by_postcode_prefix(postcode) || Neighbourhood.find_by_postcode_prefix(postcode_start) || Neighbourhood.find_by_name(area)
    end
    
    def live?
      neighbourhood && neighbourhood.live?
    end
    
    def postcode_start
      postcode.gsub(/\s.+/, '')
    end
    
    def postcode_with_uk
      "#{postcode}, UK"
    end
    
    def create_user
      names = name.split(/\.?\s+/)
      user = User.new
      user.email= email
      user.email_confirmation = email
      user.first_name = names.first
      user.last_name = names.last
      user.postcode = postcode
      user.city = PreRegistration.name_of_town(postcode)
      user
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
      
      if (neighbourhood = Neighbourhood.find_by_postcode_prefix(postcode_start))
        self.area = neighbourhood.name
      else
        address_components = results.first.data['address_components']
        town_component = address_components.select{|component| component['types'].include?('postal_town')}.first
        self.area = town_component.try(:[],'short_name')
      end
    end
    
end
