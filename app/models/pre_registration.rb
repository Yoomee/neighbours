class PreRegistration < ActiveRecord::Base
    include YmCore::Model
    validates :name, :email, :postcode, :presence => true
    validates :email, :email => true
    validates :postcode, :postcode => true
    
    before_save :set_area
    
    def coming_soon?
      if (neighbourhood = (Neighbourhood.find_by_postcode_prefix(postcode_start) || Neighbourhood.find_by_name(area)))
        if neighbourhood.live == 1
          false
        end
      end
    end
    
    def live?
      if (neighbourhood = Neighbourhood.find_by_name(area))
        neighbourhood.live
      end
    end
    
    def postcode_start
      postcode.gsub(/\s.+/, '')
    end
    
    def set_area
      if (neighbourhood = Neighbourhood.find_by_postcode_prefix(postcode_start))
        self.area = neighbourhood.name
      else
        self.area = PreRegistration.name_of_town(postcode)  
      end
    end  
    
    def create_user
      names = name.split(/\.?\s+/)
      user = User.new
      user.email= email
      user.email_confirmation = email
      user.first_name = names.first
      user.last_name = names.last
      user.password_confirmation = user.password
      user.postcode = postcode
      
      #Fake this data. TODO: fix      
      user.dob = "1900-01-01"
      user.house_number = "1"
      user.street_name = "Unknown"
      user.agreed_conditions = true
      user.validate_by = "post"
      user.password = "password"
            
      user.city = PreRegistration.name_of_town(postcode)
      user.save
      user
    end
    
    
    class << self
      def name_of_town(postcode)
        results = Geocoder.search("#{postcode}, UK")
        results.last.data['address_components'].last['long_name']
      end
   end
    
end
