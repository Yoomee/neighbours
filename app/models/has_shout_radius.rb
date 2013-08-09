module HasShoutRadius

  def self.included(base)
    base.send(:extend, ClassMethods)
    base.has_one :neighbourhood, :through => :user
    base.scope :from_live_neighbourhood, base.joins(:neighbourhood).where('neighbourhoods.live = 1')
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
  
    def visible_from_location(lat,lng, options = {})
      sphinx_options = {
        :with => { "@geodist" => 0.0..maximum_radius.to_f },
        :geo => [(lat.to_f*Math::PI/180),(lng.to_f*Math::PI/180)],
        :per_page => 100000
      }
      sphinx_options[:order] = "@geodist ASC" if options[:order_by_closest]
      sphinx_search = search_for_ids(sphinx_options)
      ids = []
      sphinx_search.results[:matches].each do |match|
        if match[:attributes]["radius"].to_f > match[:attributes]["@geodist"].to_f
          ids << match[:attributes]['id']
        end
        break if ids.size == options[:limit]
      end
      out = where("#{table_name}.id IN (?)", ids)
      if options[:order_by_closest]
        order_string = ids.reverse.collect{|id| "#{table_name}.id=#{id}"}.join(",")
        out.order(order_string)
      else
        out
      end
    end
    
    def visible_to_user(user)
      if user.try(:admin?)
        from_live_neighbourhood
      elsif user.try(:has_lat_lng?)
        from_live_neighbourhood.visible_from_location(user.lat, user.lng)
      else
        where("1 = 0")
      end
    end
    
  end
  
end

HasShoutRadius::RADIUS_OPTIONS = [
  ["About 200 yards", 0.125],
  ["1/4 mile", 0.25],
  ["1/2 mile", 0.5],
  ["1 mile",   1],
  ["2 miles",  2],
  ["5 miles",  5],
  ["10 miles", 10]
]