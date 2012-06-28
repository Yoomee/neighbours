class User < ActiveRecord::Base
  
  include YmUsers::User
  include YmCore::Multistep  

  User::CARD_TYPES = %w{visa mastercard american_express}
  
  has_many :needs
  has_many :offers
  
  attr_accessor :card_type, :card_number, :expiry_date, :security_code
  
  validates :address1, :city, :postcode, :presence => {:if => Proc.new {|u| u.current_step == "where_you_live"}}
  validates :validate_by, :presence => true, :if => :validation_step?
  validates :card_type, :card_number, :expiry_date, :security_code, :presence => true, :if => :validation_step?
  validates :card_type, :inclusion => {:in => User::CARD_TYPES}, :allow_blank => true, :if => :validation_step?
  validates :card_number, :length => {:is => 16}, :numericality => true, :allow_blank => true, :if => :validation_step?
  validates :security_code, :length => {:is => 3}, :numericality => true, :allow_blank => true, :if => :validation_step?
  validates :expiry_date, :format => {:with => /\d{2}\/\d{4}/}, :allow_blank => true, :if => :validation_step?
  
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
  
end