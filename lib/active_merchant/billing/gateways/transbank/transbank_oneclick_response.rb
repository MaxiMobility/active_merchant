module ActiveMerchant
  module Billing
    class TransbankOneclickResponse < Response

      def token
        @params['token']
      end

      def authorization
        @params['buyOrder']
      end

      def credit_card_type
        case @params['creditCardType']
        when 'Visa'
          :visa
        when 'AmericanExpress'
          :american_express
        when 'MasterCard'
          :master
        when 'Diners'
          :diners_club
        when 'Magna'
          :magna
        end
      end

      def credit_card_last_4
        @params['last4CardDigits']
      end

    end
  end
end
