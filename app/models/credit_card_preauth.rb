class CreditCardPreauth < ActiveRecord::Base

  include YmCore::Model
  
  validates_presence_of :name, :card_digits, :address1, :city, :zip

  attr_reader :credit_card

  class << self
    
    def create_from_user(user)
      ccp = CreditCardPreauth.new(
        :credit_card => user.credit_card,
        :address1 => "#{user.house_number} #{user.street_name}".strip,
        :city => user.city,
        :zip => user.postcode
      )
      ccp.save if ccp.credit_card.try(:valid?)
      return ccp
    end
    
  end

  def billing_address
    attributes.slice('name', 'address1', 'city', 'zip').merge('country' => 'GB').symbolize_keys!
  end

  def credit_card=(card)
    self.name = card.name
    self.card_digits = card.number.try(:last, 4)
    @credit_card = card
  end

  def deliver_failure_email
    attrs = {
      'Name' => name,
      'Card number' => ('**** '*3 + card_digits),
      'Address' => [address1, city, zip].join(", "),
      'Reason for failure' => reason_for_failure
    }
    UserMailer.admin_message("Credit card failed validation", "Someone's credit card failed validation. Here are the details:", attrs).deliver
  end

  def preauth!
    return false if new_record?
    if credit_card.try(:valid?)
      gateway = ActiveMerchant::Billing::PaymentSenseGateway.new(
        :login  => Settings.payment_sense.merchant_id,
        :password => Settings.payment_sense.password
      )
      response = gateway.preauth(1, credit_card, :address => {}, :billing_address => billing_address, :order_id => ref)
      self.attributes = {:success => response.success?, :message => response.message}
      output_data = response.params["transaction_output_data"]
      update_attributes(output_data.slice(:address_numeric_check_result, :post_code_check_result, :cv2_check_result))
    end
  end

  def reason_for_failure
    reasons = (address_numeric_check_result == "FAILED") ? ["wrong house number"] : []
    reasons << "wrong postcode" if post_code_check_result == "FAILED"
    reasons << "wrong cv2" if cv2_check_result == "FAILED"
    reasons.to_sentence.capitalize
  end

  def ref
    return nil if new_record?
    "#{Rails.env.development? ? 'dev' : 'stag'}-#{id}"
  end

end

CreditCardPreauth::ACCEPTED_CARDS = {
  "Visa" => "visa",
  "Mastercard" => "master"
}
