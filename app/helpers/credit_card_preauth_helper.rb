module CreditCardPreauthHelper

  def card_type_options
    ActiveMerchant::Billing::PaymentSenseGateway.supported_cardtypes.collect do |type|
      label_name = (type == :master ? 'Mastercard' : type.to_s.humanize)
      [label_name, type.to_s]
    end
  end

end