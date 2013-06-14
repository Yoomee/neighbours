module UserConcerns::PreRegistration
  
  def self.included(base)
    base.validates :full_name, :presence => true
    base.before_validation :generate_password, :if => :pre_registration?
  end
  
  def pre_registration?
    role == 'pre_registration'
  end
  
  private  
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
