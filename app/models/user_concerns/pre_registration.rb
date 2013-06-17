module UserConcerns::PreRegistration
  
  def self.included(base)
    base.before_validation :generate_password, :if => :pre_registration?
    base.before_validation :clean_up_needs_and_general_offers, :on => :create    
    base.validates :full_name, :presence => true
    base.send(:attr_accessor, :pre_register_need_or_offer)
    base.send(:boolean_accessor, :ready_for_pre_register_signup)
  end
  
  def pre_registration?
    role == 'pre_registration'
  end
  
  def pre_register_need_or_offer_valid?
    return true if pre_register_need_or_offer.blank?
    if pre_register_need_or_offer == 'need' && new_need = needs.first
      new_need.user = self
      new_need.valid?
    elsif pre_register_need_or_offer == 'general_offer' && new_general_offer = general_offers.first
      new_general_offer.user = self
      new_general_offer.valid?
    end
  end
  
  private  
  def clean_up_needs_and_general_offers
    general_offers(true) unless pre_register_need_or_offer == 'general_offer'
    needs(true) unless pre_register_need_or_offer == 'need'
  end
  
  def generate_password
    self.password = SecureRandom.hex(8)
  end
  
end

# class PreRegistration < ActiveRecord::Base
#     include YmCore::Model
#     validates :name, :email, :postcode, :presence => true
#     validates :email, :email => true
#     validates :postcode, :postcode => true
#     
#     before_save :geocode
#     
#     scope :with_lat_lng, where("lat IS NOT NULL AND lng IS NOT NULL")
#     
#     class << self
#       def name_of_town(postcode)
#         results = Geocoder.search("#{postcode}, UK")
#         address_components = results.first.data['address_components']
#         town_component = address_components.select{|component| component['types'].include?('postal_town')}.first
#         town_component.try(:[],'short_name')        
#       end
#     end
#     
#     def city
#       return nil if postcode.nil?
#       @city ||= PreRegistration.name_of_town(postcode)
#     end
#     
#     def coming_soon?
#       neighbourhood && !neighbourhood.live?
#     end
#     
#     def neighbourhood
#       Neighbourhood.find_by_postcode_or_area(postcode, area)
#     end
#     
#     def live?
#       neighbourhood && neighbourhood.live?
#     end
# 
#     def postcode_with_uk
#       "#{postcode}, UK"
#     end
#     
#     def build_user
#       attrs = attributes.symbolize_keys.slice(:email, :postcode)
#       attrs.merge!(:email_confirmation => email, :full_name => name, :city => city, :neighbourhood => neighbourhood)
#       User.new(attrs)
#     end
#     
#     def lat_lng
#       lat.present? && lng.present? ? [lat,lng] : nil
#     end
#     
#     private
#     def geocode
#       results = Geocoder.search(postcode_with_uk)
#       geometry = results.first.data['geometry']
#       self.lat = geometry['location']['lat']
#       self.lng = geometry['location']['lng']
#       
#       if neighbourhood
#         self.area = neighbourhood.name
#       else
#         address_components = results.first.data['address_components']
#         town_component = address_components.select{|component| component['types'].include?('postal_town')}.first
#         self.area = town_component.try(:[],'short_name')
#       end
#     end
#     
# end
