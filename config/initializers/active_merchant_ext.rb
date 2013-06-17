module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class PaymentSenseGateway < IridiumGateway
      
      self.money_format = :cents
      self.default_currency = 'GBP'
      self.supported_cardtypes = [ :visa, :switch, :maestro, :master, :solo, :american_express, :jcb ]
      self.supported_countries = [ 'GB' ]
      self.homepage_url = 'http://www.paymentsense.co.uk/'
      self.display_name = 'PaymentSense'
      
      def initialize(options={})
        super
        @test_url = 'https://gw1.paymentsensegateway.com:4430/'
        @live_url = 'https://gw1.paymentsensegateway.com:4430/'
      end
   
      def preauth(money, payment_source, options = {})
        setup_address_hash(options)
        commit(build_purchase_request('PREAUTH', money, payment_source, options), options)
      end
      
    end
  end
end

module ActiveMerchant  
  module Billing  
    class CreditCard  
      def persisted?  
        false  
      end  
    end  
  end  
end

ActiveMerchant::Billing::Base.mode = :test