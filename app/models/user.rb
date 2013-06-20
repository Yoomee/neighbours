class User < ActiveRecord::Base

  User::CARD_TYPES = %w{visa mastercard american_express}
  User::ORGANISATIONS = ["South Yorkshire Housing Association", "Maltby Model Village Community Association", "Neighbours Can Help", "Manor & Castle Development Trust", "Maltby Academy"]

  include YmUsers::User
  include YmCore::Multistep
  include UserConcerns::PreRegistration
  include UserConcerns::Validations

  devise :confirmable
  devise :token_authenticatable

  has_many :needs, :dependent => :destroy
  has_many :offers, :dependent => :destroy
  has_many :general_offers, :dependent => :destroy
  has_many :flags, :dependent => :destroy
  has_many :neighbourhoods_as_admin, :class_name => "Neighbourhood", :foreign_key => :admin_id
  has_many :owned_groups, :class_name => 'Group'
  has_and_belongs_to_many :groups, :uniq => true
  has_many :group_invitations, :dependent => :destroy
  has_many :photos, :dependent => :nullify

  has_many :community_members, :class_name => "User", :foreign_key => :community_champion_id, :dependent => :nullify
  belongs_to :community_champion, :class_name => "User"
  belongs_to :neighbourhood

  accepts_nested_attributes_for :needs, :general_offers

  attr_accessor :credit_card_preauth

  # accessors below are used in group_registrations#create
  attr_accessor :group_invitation_id
  boolean_accessor :seen_group_invitation_email_warning

  before_create :generate_validation_code
  before_save :set_neighbourhood, :ensure_authentication_token
  after_validation :geocode, :if => :address_changed?  
  after_create :update_existing_group_invitations
  before_update :change_email_if_deleted

  scope :with_lat_lng, where("lat IS NOT NULL AND lng IS NOT NULL")
  scope :not_deleted, where(:is_deleted => false)
  scope :deleted, where(:is_deleted => true)
  scope :validated, not_deleted.where(:validated => true)
  scope :unvalidated, not_deleted.where(:validated => false)
  scope :community_champions, not_deleted.where(:is_community_champion => true)
  scope :community_champion_requesters, not_deleted.where("champion_request_at IS NOT NULL").order("champion_request_at DESC")
  scope :in_sheffield, not_deleted.where("postcode LIKE 'S%'")
  scope :not_in_sheffield, not_deleted.where("postcode NOT LIKE 'S%'")

  define_index do
    indexes first_name
    has id
    has "RADIANS(lat)", :as => :latitude,  :type => :float
    has "RADIANS(lng)", :as => :longitude, :type => :float
    set_property :delta => true
  end
  
  class << self
    
    def visible_to_user(user)
      validated.within_radius(user.lat, user.lng, user.try(:neighbourhood).try(:max_radius))
    end
    
    def within_radius(lat, lng, radius = nil)
      radius ||= Need::maximum_radius
      sphinx_search = search_for_ids({
        :with => { "@geodist" => 0.0..radius.to_f },
        :geo => [(lat.to_f*Math::PI/180), (lng.to_f*Math::PI/180)],
        :per_page => 100000
      })
      ids = sphinx_search.results[:matches].collect { |res| res[:attributes]['id'] }
      where("users.id IN (?)", ids)
    end
    
  end
  
  def after_token_authentication
    self.update_attribute(:authentication_token, nil)
  end

  def address_changed?
    house_number_changed? || street_name_changed? || postcode_changed?
  end

  def address
    ["#{house_number} #{street_name}".strip, city, postcode].reject(&:blank?).join(', ')
  end

  def address_with_country
    "#{address}, UK"
  end

  def city
    read_attribute(:city).presence || "Sheffield"
  end

  def credit_card
    @credit_card ||= ActiveMerchant::Billing::CreditCard.new
  end
    
  def credit_card_attributes=(attrs)  
    attrs.reject!{|a| a.blank?}
    @credit_card = ActiveMerchant::Billing::CreditCard.new(attrs)  
  end

  # overwritten devise method: users don't need to confirm their email address, so everyone is confirmed
  def confirmed?
    true
  end

  def group_user?
    role == 'group_user'
  end

  def has_address?
    all_present?(:house_number, :street_name, :city, :postcode)
  end
  
  def has_lat_lng?
    all_present?(:lat, :lng)
  end
  
  def is_neighbourhood_admin?
    neighbourhoods_as_admin.count > 0
  end

  def lat_lng
    lat.present? && lng.present? ? [lat,lng] : nil
  end

  def new_notification_count(context, need = nil)
    if need
      need.notifications.where(:context => context, :user_id => id, :read => false).count
    else
      notifications.where(:context => context, :read => false).count
    end
  end

  def radius_options
    Need.radius_options((neighbourhood.try(:max_radius_in_miles) || Neighbourhood::DEFAULT_MAX_RADIUS_IN_MILES).to_f)
  end

  def current_step
    @current_step
  end

  def steps
    %w{who_you_are where_you_live validate}
  end

  def to_s
    first_name
  end

  def validation_code
    code = read_attribute(:validation_code).to_s
    "#{code[0..3]} #{code[4..7]}".strip
  end

  def wall_posts
    Post.where(["target_type = 'User' AND target_id = ?", id])
  end

  private
  def change_email_if_deleted
    return true if !is_deleted? || email.starts_with?("deleted-#{id}-")
    self.email = "deleted-#{id}-#{email}"
  end
  
  def generate_validation_code
    return true if validation_code.present?
    unique_code = nil
    while unique_code.nil? || User.exists?(:validation_code => unique_code)
      unique_code = SecureRandom.hex(4).upcase
    end
    self.validation_code = unique_code
  end

  def geocode
    results = Geocoder.search(address_with_country)
    geometry = results.first.data['geometry']
    self.lat = geometry['location']['lat']
    self.lng = geometry['location']['lng']
    return true if read_attribute(:city).present?
    if neighbourhood
      self.city = neighbourhood.name
    else
      address_components = results.first.data['address_components']
      town_component = address_components.select{|component| component['types'].include?('postal_town')}.first
      self.city = town_component.try(:[],'short_name')
    end
  end

  def set_neighbourhood
    unless neighbourhood
      self.neighbourhood = Neighbourhood.find_by_postcode_or_area(postcode)
    end
  end

  def update_existing_group_invitations
    GroupInvitation.where(['user_id IS NULL AND email = ?', email]).update_all(:user_id => id)
  end

  protected  
  def confirmation_required?
    false
  end

end