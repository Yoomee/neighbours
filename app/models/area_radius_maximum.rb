class AreaRadiusMaximum < ActiveRecord::Base
  
  belongs_to :neighbourhood
  
  validates :postcode_fragment, :maximum_radius, :presence => true
  validates :maximum_radius, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates :maximum_radius_in_miles, :numericality => { :greater_than_or_equal_to => 0 }
  
  default_scope order(:postcode_fragment)
  
  def self.find_all_postcode_fragments_and_create_new_area_radium_maximums
    postcode_fragments = User.where("postcode IS NOT NULL AND postcode != ''").select("SUBSTRING_INDEX(postcode,' ', 1)  AS postcode_fragment").group("postcode_fragment").collect(&:postcode_fragment)
    
    postcode_fragments.each do |postcode_fragment|
      unless AreaRadiusMaximum.exists?(:postcode_fragment => postcode_fragment)
        AreaRadiusMaximum.create(:neighbourhood_id => 1, :postcode_fragment => postcode_fragment, :maximum_radius => AreaRadiusMaximum::DEFAULT_MAXIMUM) 
      end
    end
  end
    
  def maximum_radius_in_miles
    (maximum_radius.to_i / 1609.344).round(2).to_s.chomp(".0")
  end
  
  def maximum_radius_in_miles=(value)
    self.maximum_radius = ( value.to_f * 1609.344).round
  end
  
end

AreaRadiusMaximum::DEFAULT_MAXIMUM = (5 * 1609.344).round