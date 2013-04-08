class User < ActiveRecord::Base

  include YmUsers::User
  include YmCore::Multistep

  devise :confirmable

  User::CARD_TYPES = %w{visa mastercard american_express}
  User::ORGANISATIONS = ["South Yorkshire Housing Association", "Maltby Model Village Community Association", "Maltby Academy", "Maltby Town Council"]

  has_many :needs, :dependent => :destroy
  has_many :offers, :dependent => :destroy
  has_many :flags, :dependent => :destroy
  has_many :neighbourhoods_as_admin, :class_name => "Neighbourhood"

  has_many :community_members, :class_name => "User", :foreign_key => :community_champion_id, :dependent => :nullify
  belongs_to :community_champion, :class_name => "User"
  belongs_to :neighbourhood

  attr_accessor :card_number, :card_security_code

  before_create :generate_validation_code
  after_create :send_emails
  before_save :set_card_digits, :set_neighbourhood
  after_validation :add_errors_to_confirmation_fields, :add_password_errors_for_who_you_are_step

  geocoded_by :address_with_country, :latitude => :lat, :longitude => :lng
  after_validation :geocode,  :if => lambda{ |obj| obj.address_changed? }
  after_validation :allow_non_unique_email_if_deleted

  validates :house_number, :street_name, :city, :presence => {:if => :where_you_live_step?}
  validates :postcode, :postcode => {:if => :where_you_live_step?}, :allow_blank => true
  validates :validate_by, :presence => true, :if => :validation_step?
  validates :organisation_name, :presence => true, :if => :validation_step_with_organisation?
  validates :card_type, :card_number, :card_expiry_date, :card_security_code, :presence => true, :if => :validation_step_with_credit_card?
  validates :card_type, :inclusion => {:in => User::CARD_TYPES}, :allow_blank => true, :if => :validation_step_with_credit_card?
  validates :card_number, :length => {:is => 16}, :numericality => true, :allow_blank => true, :if => :validation_step_with_credit_card?
  validates :card_security_code, :length => {:is => 3}, :numericality => true, :allow_blank => true, :if => :validation_step_with_credit_card?
  validates :card_expiry_date, :format => {:with => /\d{2}\/\d{4}/}, :allow_blank => true, :if => :validation_step_with_credit_card?
  validates :agreed_conditions, :inclusion => { :in => [true], :if => :validation_step?, :message => "You must accept our terms and conditions to continue" }
  validate :dob_or_undiclosed_age
  validate :over_16
  validates_confirmation_of :email, :on => :create, :message => "these don't match"
  validates_confirmation_of :password, :on => :create, :message => "these didn't match"
  validates :email_confirmation, :presence => {:if => :who_you_are_step?}
  validates :password_confirmation, :presence => {:if => Proc.new{|u| u.who_you_are_step? && u.password.blank?}}
  validates :validation_code, :uniqueness => true

  scope :validated, where(:validated => true, :is_deleted => false)
  scope :unvalidated, where(:validated => false, :is_deleted => false)
  scope :community_champions, where(:is_community_champion => true, :is_deleted => false)
  scope :community_champion_requesters, where("champion_request_at IS NOT NULL AND is_deleted = false").order("champion_request_at DESC")
  scope :with_lat_lng, where("lat IS NOT NULL AND lng IS NOT NULL")
  scope :in_sheffield, where("postcode LIKE 'S%' AND is_deleted = false")
  scope :not_in_sheffield, where("postcode NOT LIKE 'S%' AND is_deleted = false")
  scope :deleted, where(:is_deleted => true)

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

  # overwritten devise method: users don't need to confirm their email address, so everyone is confirmed
  def confirmed?
    true
  end

  def credit_card_attributes
    %w{card_type formatted_card_number card_expiry_date}
  end

  def dob_or_undiclosed_age
    dob.present? || undisclosed_age?
  end

  def formatted_card_number
    return nil if card_digits.blank?
    ("**** " * 3) + card_digits.to_s
  end

  def has_address?
    all_present?(:house_number, :street_name, :city, :postcode)
  end
  
  def has_lat_lng?
    lat.present? && lng.present?
  end

  def new_notification_count(context, need = nil)
    if need
      need.notifications.where(:context => context, :user_id => id, :read => false).count
    else
      notifications.where(:context => context, :read => false).count
    end
  end

  def radius_options
    max_radius = AreaRadiusMaximum.find_by_postcode_fragment(postcode.to_s.split[0].to_s.strip).try(:maximum_radius_in_miles) || AreaRadiusMaximum::DEFAULT_MAXIMUM
    Need.radius_options.select { |k,v| v <= (max_radius.to_i * 1609.344).round }
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

  def set_card_digits
    unless card_number.blank?
      self.card_digits = card_number.last(4)
    end
  end

  protected
  def confirmation_required?
    false
  end

end