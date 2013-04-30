module HasShoutRadius

  def self.included(base)
    base.send(:extend, ClassMethods)
  end

  module ClassMethods

    def default_radius
      radius_options[2].last
    end
    
    def maximum_radius
      radius_options.last.last
    end
        
    def radius_options(max_miles = nil)
      max_miles ||= HasShoutRadius::RADIUS_OPTIONS.last.last
      HasShoutRadius::RADIUS_OPTIONS.map do |name, miles|
        [name, (miles * 1609.344).round]
      end.select { |k,v| v <= (max_miles * 1609.344).round }
    end
  
    def visible_from_location(lat,lng)
      sphinx_search = search_for_ids({
        :with => { "@geodist" => 0.0..maximum_radius.to_f },
        :geo => [(lat.to_f*Math::PI/180),(lng.to_f*Math::PI/180)],
        :per_page => 100000
      })
      ids = []
      sphinx_search.results[:matches].each do |match|
        if match[:attributes]["radius"].to_f > match[:attributes]["@geodist"].to_f
          ids << match[:attributes]['id']
        end
      end
      where("#{table_name}.id IN (?)", ids)
    end
    
    def visible_to_user(user)
      if user.try(:admin?)
        where("1 = 1")
      elsif user.try(:has_lat_lng?)
        visible_from_location(user.lat, user.lng)
      else
        where("1 = 0")
      end
    end
    
  end
  
end

HasShoutRadius::RADIUS_OPTIONS = [
  ["1/4 mile", 0.25],
  ["1/2 mile", 0.5],
  ["1 mile",   1],
  ["2 miles",  2],
  ["5 miles",  5],
  ["10 miles", 10]
]