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
    
    
    class << self
      def name_of_town(postcode)
        results = Geocoder.search(postcode)
        results.last.data['address_components'].last['long_name']
      end
   end
    
end
