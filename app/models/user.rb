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
  has_many :credit_card_preauths

  has_many :community_members, :class_name => "User", :foreign_key => :community_champion_id, :dependent => :nullify
  belongs_to :community_champion, :class_name => "User"
  belongs_to :neighbourhood

  accepts_nested_attributes_for :credit_card_preauths, :limit => 1

  before_create :generate_validation_code
  after_create :send_emails
  before_save :set_neighbourhood
  after_validation :add_errors_to_confirmation_fields, :add_password_errors_for_who_you_are_step
  before_validation :setup_credit_card_preauth
  before_create :validate_credit_card_address

  geocoded_by :address_with_country, :latitude => :lat, :longitude => :lng
  after_validation :geocode,  :if => lambda{ |obj| obj.address_changed? }
  after_validation :allow_non_unique_email_if_deleted

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

  scope :with_lat_lng, where("lat IS NOT NULL AND lng IS NOT NULL")
  scope :not_deleted, where(:is_deleted => false)
  scope :deleted, where(:is_deleted => true)
  scope :validated, not_deleted.where(:validated => true)
  scope :unvalidated, not_deleted.where(:validated => false)
  scope :community_champions, not_deleted.where(:is_community_champion => true)
  scope :community_champion_requesters, not_deleted.where("champion_request_at IS NOT NULL").order("champion_request_at DESC")
  scope :in_sheffield, not_deleted.where("postcode LIKE 'S%'")
  scope :not_in_sheffield, not_deleted.where("postcode NOT LIKE 'S%'")

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

  # def credit_card_preauths_attributes_with_address_fields=(attrs)
  #   attrs.keys.each do |key|
  #     attrs[key]["house_number"] ||= self.house_number
  #     attrs[key]["street_name"] ||= self.street_name
  #     attrs[key]["city"] ||= self.city
  #     attrs[key]["postcode"] ||= self.postcode
  #   end
  #   credit_card_preauths_attributes_without_address_fields(value)
  # end
  # alias_method_chain :credit_card_preauths_attributes, :address_fields

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
    lat.present? && lng.present?
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

  def setup_credit_card_preauth
    if validation_step? && validate_by == 'credit_card'
      credit_card_preauths.build if credit_card_preauths.empty?
    else
      credit_card_preauths(true)
    end
  end

  def validate_credit_card_address
    return true if !validation_step? || validate_by != 'credit_card'
    credit_card_preauth = credit_card_preauths.select(&:new_record?).first
    attrs = attributes.slice('house_number', 'street_name', 'city', 'postcode')
    attrs.merge!(credit_card_preauth.attributes)
    attrs.merge!(:card_number => credit_card_preauth.card_number, 
        :card_expiry_date => credit_card_preauth.card_expiry_date,
        :card_security_code => credit_card_preauth.card_security_code
    )
    credit_card_preauths(true)
    if new_credit_card_preauth = CreditCardPreauth.new(attrs)
      self.validated = new_credit_card_preauth.preauth!
    else
      raise CreditCardPreauthFailedError
    end
  end

  protected
  def confirmation_required?
    false
  end

end