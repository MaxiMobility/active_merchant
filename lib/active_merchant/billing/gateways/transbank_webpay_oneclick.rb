module ActiveMerchant #:nodoc:
  module Billing #:nodoc:

    #
    # = Transbank Webpay Oneclick Gateway
    #
    # Only supported in Chile by Transbank. Based on a SOAP interface,
    # this library provides access to the methods used to initiate a
    # payment and tigger storage of the user's card details.
    #
    # Transbank currently only allow new cardholder details to be provided
    # on their hosted web pages. These always take the client through their
    # authorizing banks authentication process, similar to 3D Secure.
    #
    # Once details have been secured, purchases and refunds can be made
    # using the provided token.
    #
    # In effect, this gateway has more in common with PayPal Express than any
    # of the others.
    #
    # Method names for non-standard operations, such as inscription, are
    # based on the operation names provided by Transbank.
    #
    # == Using
    #
    # Configure the gateway with the private key, whose public part you provided
    # to transbank:
    #
    #    gateway = ActiveMerchant::Billing::TransbankWebpayOneclickGateway.new(
    #      :pem => Rails.root.join('config', 'company.key')
    #    )
    #
    # A subscribe request must first be performed to know where to forward the user:
    #
    #    gatway.init_inscription(
    #      :username   => 'someuser',
    #      :email      => 'client@email.com',
    #      :return_url => 'https://XYZ.com'
    #    )
    #
    # One of either :username or :email should be provided.
    #
    #
    class TransbankWebpayOneclickGateway < Gateway

      self.test_url = 'https://example.com/test'
      self.live_url = 'https://webpay3gdesa.transbank.cl/webpayserver/wswebpay/OneClickPaymentService'

      # The countries the gateway supports merchants from as 2 digit ISO country codes
      self.supported_countries = ['CL']

      # The card types supported by the payment gateway
      self.supported_cardtypes = [:visa, :master, :american_express, :discover]

      # The homepage URL of the gateway
      self.homepage_url = 'http://www.webpay.cl'

      # The name of the gateway
      self.display_name = 'New Gateway'

      # The Transbank server public key
      self.server_pem = File.read(File.dirname(__FILE__) + '/transbank/server.pem')

      def initialize(options = {})
        #requires!(options, :login, :password)
        super
      end

      #### Subscription Handling


      def init_inscription(options = {})

      end

      def finish_inscription(token, options = {})

      end

      def remove_user(token, options = {})

      end


      #### Regular Active Merchant Methods

      def purchase(money, token, options = {})
        post = {}
        add_invoice(post, options)
        add_creditcard(post, creditcard)
        add_address(post, creditcard, options)
        add_customer_data(post, options)

        commit('sale', money, post)
      end

      def refund(money, authorization, options = {})
        commit('capture', money, post)
      end

      private

      def build_

      def add_customer_data(post, options)
      end

      def add_address(post, creditcard, options)
      end

      def add_invoice(post, options)
      end

      def add_creditcard(post, creditcard)
      end


      def build_request(body, options)
        xml = Builder::XmlMarkup.new :indent => 2
          xml.instruct!
          xml.tag! 'soap:Envelope', {'xmlns:soap' => 'http://schemas.xmlsoap.org/soap/envelope/', 'xmlns:xsd' => "http://www.w3.org/2001/XMLSchema", 'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance"} do
            xml.tag! 'soap:Header' do
              xml.tag! 'wsse:Security', {'s:mustUnderstand' => '1', 'xmlns:wsse' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd'} do
              end
            end
            xml.tag! 'soap:Body', {'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance', 'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema'} do
              xml.tag! 'requestMessage', {'xmlns' => "urn:schemas-cybersource-com:transaction-data-#{XSD_VERSION}"} do
                add_merchant_data(xml, options)
                xml << body
              end
            end
          end
        xml.target!

      end

      # Parse the SOAP response
      # Technique inspired by the Paypal Gateway
      def parse(xml)
        reply = {}
        xml = REXML::Document.new(xml)
        if root = REXML::XPath.first(xml, "//c:replyMessage")
          root.elements.to_a.each do |node|
            case node.name
            when 'c:reasonCode'
              reply[:message] = reply(node.text)
            else
              parse_element(reply, node)
            end
          end
        elsif root = REXML::XPath.first(xml, "//soap:Fault")
          parse_element(reply, root)
          reply[:message] = "#{reply[:faultcode]}: #{reply[:faultstring]}"
        end
        return reply
      end

      def parse_element(reply, node)
        if node.has_elements?
          node.elements.each{|e| parse_element(reply, e) }
        else
          if node.parent.name =~ /item/
            parent = node.parent.name + (node.parent.attributes["id"] ? "_" + node.parent.attributes["id"] : '')
            reply[(parent + '_' + node.name).to_sym] = node.text
          else
            reply[node.name.to_sym] = node.text
          end
        end
        return reply
      end

      def commit(action, money, parameters)
      end

      def message_from(response)
      end

      def post_data(action, parameters = {})
      end
    end
  end
end

