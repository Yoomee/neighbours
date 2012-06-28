class User < ActiveRecord::Base
  
  include YmUsers::User
  include YmCore::Multistep  
  
  has_many :needs
  has_many :offers
  
  validates :address1, :city, :postcode, :presence => {:if => Proc.new {|u| u.current_step == "where_you_live"}}
  validates :validate_by, :presence => {:if => Proc.new {|u| u.current_step == "validate"}}
  
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
  
end