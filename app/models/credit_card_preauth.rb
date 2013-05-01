class CreditCardPreauth < ActiveRecord::Base

  include YmCore::Model

  belongs_to :user
  
  validates_presence_of :card_type, :card_number, :card_digits, :card_expiry_date, :card_security_code #, :house_number, :street_name, :city, :postcode
  validates :card_type, :inclusion => {:in => ActiveMerchant::Billing::PaymentSenseGateway.supported_cardtypes.collect(&:to_s)}, :allow_blank => true
  validates :card_number, :length => {:is => 16}, :numericality => true, :allow_blank => true
  validates :card_security_code, :length => {:is => 3}, :numericality => true, :allow_blank => true
  validates :card_expiry_date, :format => {:with => /\d{2}\/\d{4}/}, :allow_blank => true

  before_validation :save_card_digits

  attr_accessor :card_number, :card_expiry_date, :card_security_code

  delegate :full_name, :first_name, :last_name, :house_number, :street_name, :city, :postcode, :to => :user, :allow_nil => true

  def billing_address
    {
      :name => full_name,
      :address1 => "#{house_number} #{street_name}".strip,
      :city => city,
      :country => 'GB',
      :zip => postcode
    }
  end

  def card_details
    {
      :number => card_number,
      :month => card_expiry_date.split("/")[0],
      :year => card_expiry_date.split("/")[1],
      :first_name => first_name,
      :last_name => last_name,
      :verification_value => card_security_code,
      :type => card_type
    }
  end

  def preauth!
    credit_card = ActiveMerchant::Billing::CreditCard.new(card_details)
    if credit_card.valid?
      gateway = ActiveMerchant::Billing::PaymentSenseGateway.new(
        :login  => Settings.payment_sense.merchant_id,
        :password => Settings.payment_sense.password
      )
      response = gateway.preauth(1, credit_card, :address => {}, :billing_address => billing_address, :order_id => self.id)
      unless response.success?
        update_attribute(:failed_message, response.message)
        raise CreditCardPreauthFailedError
      end
    end
  end

  private
  def save_card_digits
    return true if card_number.blank?
    self.card_digits = card_number.last(4)
  end

end

class CreditCardPreauthFailedError < StandardError; end

# CreditCardPreauth::TEST_CARD = {
#   :number => '4976000000003436',
#   :month => 12,
#   :year => 2015,
#   :first_name => 'John',
#   :last_name => 'Watson',
#   :verification_value => '452',
#   :type => 'visa'
# }
