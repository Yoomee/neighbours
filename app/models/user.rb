class User < ActiveRecord::Base

  include YmUsers::User
  include YmCore::Multistep

  devise :confirmable

  User::ORGANISATIONS = ["South Yorkshire Housing Association", "Maltby Model Village Community Association", "Neighbours Can Help", "Manor & Castle Development Trust", "Maltby Academy"]

  has_many :needs, :dependent => :destroy
  has_many :offers, :dependent => :destroy
  has_many :general_offers, :dependent => :destroy
  has_many :flags, :dependent => :destroy
  has_many :neighbourhoods_as_admin, :class_name => "Neighbourhood", :foreign_key => :admin_id

  has_many :community_members, :class_name => "User", :foreign_key => :community_champion_id, :dependent => :nullify
  belongs_to :community_champion, :class_name => "User"
  belongs_to :neighbourhood

  before_create :generate_validation_code
  after_create :send_emails
  before_save :set_neighbourhood
  after_validation :add_errors_to_confirmation_fields, :add_password_errors_for_who_you_are_step

  geocoded_by :address_with_country, :latitude => :lat, :longitude => :lng
  after_validation :geocode,  :if => lambda{ |obj| obj.address_changed? }
  after_validation :allow_non_unique_email_if_deleted

  attr_accessor :credit_card_preauth

  validates :house_number, :street_name, :city, :presence => {:if => :where_you_live_step?}
  validates :postcode, :postcode => {:if => :where_you_live_step?}, :allow_blank => true
  validates :validate_by, :presence => {:if => :validation_step?, :message => "Please click on one of the options below"}
  validates :organisation_name, :presence => true, :if => :validation_step_with_organisation?
  validates :agreed_conditions, :inclusion => { :in => [true], :if => :validation_step?, :message => "You must accept our terms and conditions to continue" }
  validate :dob_or_undiclosed_age
  validate :over_16
  validates_confirmation_of :email, :on => :create, :message => "these don't match"
  validates_confirmation_of :password, :on => :create, :message => "these didn't match"
  validates :email_confirmation, :presence => {:if => :who_you_are_step?}
  validates :password_confirmation, :presence => {:if => Proc.new{|u| u.who_you_are_step? && u.password.blank?}}
  validates :validation_code, :uniqueness => true
  validate :preauth_credit_card, :if => :validation_step?

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

  def address_changed?
    house_number_changed? || street_name_changed? || postcode_changed?
  end

  def address
    ["#{house_number} #{street_name}".strip, city, postcode].compact.join(', ')
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

  def dob_or_undiclosed_age
    dob.present? || undisclosed_age?
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

  def validation_step?
    current_step == "validate"
  end

  def validation_step_with_credit_card?
    validation_step? && validate_by == "credit_card"
  end

  def validation_step_with_organisation?
    validation_step? && validate_by == "organisation"
  end

  def wall_posts
    Post.where(["target_type = 'User' AND target_id = ?", id])
  end

  def who_you_are_step?
    new_record? && current_step == "who_you_are"
  end

  def where_you_live_step?
    current_step == "where_you_live"
  end
  
  def users_within_radius
    User.within_radius(lat, lng, neighbourhood.try(:max_radius))
  end

  private
  def add_errors_to_confirmation_fields
    return true if !who_you_are_step?
    [:email, :password].each do |attr_name|
      if errors[attr_name].any? {|m| m.match(/match/)}
        errors.add("#{attr_name}_confirmation", errors[attr_name].detect {|m| m.match(/match/)})
      end
    end
  end

  def add_password_errors_for_who_you_are_step
    return true if !who_you_are_step?
    if errors.present?
      errors.add(:password, "enter a password") unless errors[:password].present?
      errors.add(:password_confirmation, "enter a password") unless errors[:password_confirmation].present?
    end
  end
  
  def allow_non_unique_email_if_deleted
    return true if errors.messages.blank? || (email_errors_messages = errors.messages.delete(:email)).blank?
    non_unique_message = I18n.t("activerecord.errors.models.user.attributes.email.taken")
    if email_errors_messages.delete(non_unique_message) && User.exists?(:email => email, :is_deleted => false)
      email_errors_messages << non_unique_message
    end
    email_errors_messages.each do |message|
      self.errors.add(:email,message)
    end
  end
  
  def send_emails
    if validate_by == "post"
      UserMailer.new_registration_with_post_validation(self).deliver
    elsif validate_by == "organisation"
      UserMailer.new_registration_with_organisation_validation(self).deliver
    end
    UserMailer.admin_message("A new user has just registered on the site", "You will be delighted to know that a new user has just registered on the site.\n\nHere are all the gory details:", self.attributes).deliver
  end

  def set_neighbourhood
    unless neighbourhood
      self.neighbourhood = Neighbourhood.find_by_postcode_or_area(postcode)
    end
  end

  def generate_validation_code
    return true if validation_code.present?
    unique_code = nil
    while unique_code.nil? || User.exists?(:validation_code => unique_code)
      unique_code = SecureRandom.hex(4).upcase
    end
    self.validation_code = unique_code
  end

  def over_16
    return true if undisclosed_age? || admin?
    errors.add(:dob, "You must be over 16 to register") unless dob.present? && dob < 16.years.ago.to_date
  end

  def credit_card_valid?
    credit_card.name = full_name
    card_valid = credit_card.valid?
    if !credit_card.brand.in?(CreditCardPreauth::ACCEPTED_CARDS.values)
      credit_card.errors.add(:brand, "please select an accepted card type")
      card_valid = false
    end
    errors.add(:credit_card, "card details are invalid") if !card_valid
    card_valid
  end

  def preauth_credit_card
    if validate_by == 'credit_card' && credit_card_valid? && agreed_conditions?
      return true if credit_card_preauth.present?
      self.credit_card_preauth = CreditCardPreauth.create_from_user(self)
      credit_card_preauth.preauth!
      if credit_card_preauth.success?
        self.validated = true
      else
        errors.add(:credit_card_details, "Unfortunately we couldn't verify your address from the card details you entered. Please check your card details or select an alternative validation option.")
      end
    end
  end

  protected
  def confirmation_required?
    false
  end

end