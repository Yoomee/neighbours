class User < ActiveRecord::Base
  
  include YmUsers::User
  include YmCore::Multistep  

  User::CARD_TYPES = %w{visa mastercard american_express}
  User::ORGANISATIONS = ["Housing Association", "Neighbourhood watch"]
  
  has_many :needs
  has_many :offers
  
  attr_accessor :card_number, :card_security_code
  
  before_save :set_card_digits
  
  validates :address1, :city, :postcode, :presence => {:if => Proc.new {|u| u.current_step == "where_you_live"}}
  validates :validate_by, :presence => true, :if => :validation_step?
  validates :organisation_name, :presence => true, :if => :validation_step_with_organisation?
  validates :card_type, :card_number, :card_expiry_date, :card_security_code, :presence => true, :if => :validation_step_with_credit_card?
  validates :card_type, :inclusion => {:in => User::CARD_TYPES}, :allow_blank => true, :if => :validation_step_with_credit_card?
  validates :card_number, :length => {:is => 16}, :numericality => true, :allow_blank => true, :if => :validation_step_with_credit_card?
  validates :card_security_code, :length => {:is => 3}, :numericality => true, :allow_blank => true, :if => :validation_step_with_credit_card?
  validates :card_expiry_date, :format => {:with => /\d{2}\/\d{4}/}, :allow_blank => true, :if => :validation_step_with_credit_card?
  
  scope :validated, where(:validated => true)
  scope :unvalidated, where(:validated => false)
  
  def address
    [address1, city, county, postcode].compact.join(', ')
  end
  
  def credit_card_attributes
    %w{card_type formatted_card_number card_expiry_date}
  end
  
  def formatted_card_number
    return nil if card_digits.blank?
    ("**** " * 3) + card_digits.to_s
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
  
  private
  def set_card_digits
    unless card_number.blank?
      self.card_digits = card_number.last(4)
    end
  end
  
end