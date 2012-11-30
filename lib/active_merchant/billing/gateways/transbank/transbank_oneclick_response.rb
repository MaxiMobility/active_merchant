module ActiveMerchant
  module Billing
    class TransbankOneclickResponse < Response

      def token
        @params[:token] || @params[:tbkUser]
      end

      def redirect_url
        @params[:redirect_url]
      end

      def authorization
        @params[:transactionId]
      end

    end
  end
end
