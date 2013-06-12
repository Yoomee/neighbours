module PaymentSense

  TEST_CARD = {
    :number => '4976000000003436',
    :month => 12,
    :year => 2015,
    :first_name => 'John',
    :last_name => 'Watson',
    :verification_value => '452',
    :type => 'visa'
  }
  LOGIN_ID = 'NEIGHB-3298248'
  TRANSACTION_KEY = "T46Q8G4J9F"


  def preauth
    ActiveMerchant::Billing::Base.mode = :test

    billing_address = { :name => 'John Watson', :address1 => '34 Edward Street',
    :city => 'Camborne', :state => 'Cornwall',
    :country => 'GB', :zip => 'TR14 8PA', :phone => '(555)555-5555' }

    credit_card = ActiveMerchant::Billing::CreditCard.new(TEST_CARD)

    if credit_card.valid?
      gateway = ActiveMerchant::Billing::PaymentSenseGateway.new(
      :login  => LOGIN_ID,
      :password => TRANSACTION_KEY
      )
    
      options = {:address => {}, :billing_address => billing_address, :order_id => Random.rand(100)}
      response = gateway.preauth(1, credit_card, options)

      if response.success?
        puts response.inspect
      else
        raise StandardError.new( response.message )
      end
    end
  end

end