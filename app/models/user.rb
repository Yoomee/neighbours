class User < ActiveRecord::Base
  
  include YmUsers::User
  include YmCore::Multistep  

  User::CARD_TYPES = %w{visa mastercard american_express}
  User::ORGANISATIONS = %w{housing_association organisation_2 organisation_3 organisation_4}
  
  has_many :needs
  has_many :offers
  
  attr_accessor :card_type, :card_number, :expiry_date, :security_code, :organisation_name
  
  validates :address1, :city, :postcode, :presence => {:if => Proc.new {|u| u.current_step == "where_you_live"}}
  validates :validate_by, :presence => true, :if => :validation_step?
  validates :organisation_name, :presence => true, :if => :validation_step_with_organisation?
  validates :card_type, :card_number, :expiry_date, :security_code, :presence => true, :if => :validation_step_with_credit_card?
  validates :card_type, :inclusion => {:in => User::CARD_TYPES}, :allow_blank => true, :if => :validation_step_with_credit_card?
  validates :card_number, :length => {:is => 16}, :numericality => true, :allow_blank => true, :if => :validation_step_with_credit_card?
  validates :security_code, :length => {:is => 3}, :numericality => true, :allow_blank => true, :if => :validation_step_with_credit_card?
  validates :expiry_date, :format => {:with => /\d{2}\/\d{4}/}, :allow_blank => true, :if => :validation_step_with_credit_card?
  
  scope :validated, where(:validated => true)
  scope :unvalidated, where(:validated => false)
  
  def address
    [address1, city, county, postcode].compact.join(', ')
  end
  
  def has_address?
    %w{address1 city postcode}.all?(&:present?)
  end
  
  def steps
    %w{who_you_are where_you_live validate}
  end
  
  def to_s
    first_name
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
  
end