
# Sorry, nokogiri is requires for the canonicalization stuff :-(
require 'nokogiri'
require 'openssl'

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
    #      :merchant_id => 12345678910,
    #      :private_key => File.read(Rails.root.join('config', 'oneclick.key')),
    #      :certificate => File.read(Rails.root.join('config', 'oneclick.crt'))
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
    # Both :username and :email are required. The username is used for purely visual
    # confirmation in the Transbank WebPay screens.
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
      #self.server_pem = File.read(File.dirname(__FILE__) + '/transbank/server.pem')

      # Creates a new instance
      #
      # The merchant_id and private_key are require by this gateway.
      #
      def initialize(options = {})
        requires!(options, :merchant_id, :private_key)
        super
      end

      #### Subscription Handling


      def init_inscription(options = {})
        requires!(options, :username, :email, :return_url)

        data = {}
        add_return_url(data, options[:return_url])
        add_customer_details(data, options)

        commit :init_inscription, data
      end

      def finish_inscription(token, options = {})
        data = {}
        add_token(data, token)

        commit :finish_inscription, data
      end

      def remove_user(token, options = {})
        requires!(options, :username)

        data = {}
        add_token(data, token)
        add_customer_details(options)

        commit :remove_user, data
      end


      #### Regular Active Merchant Methods

      def purchase(money, token, options = {})
        requires!(options, :order_id)

        data = {}
        add_amount(data, money)
        add_order(data, options[:order_id])
        add_customer_details(data, options)
        add_token(data, token)

        commit :authorise_body, data
      end

      def refund(money, authorization, options = {})
        data = {}
        add_order(data, authorization)

        commit :reverse, data
      end

      private

      def add_amount(data, money)
        data[:amount] = amount(money).to_s
      end

      def add_order(data, order_id)
        data[:order_id] = order_id
      end

      def add_token(data, token)
        data[:token] = token
      end

      def add_return_url(data, url)
        data[:return_url] = url
      end

      def add_customer_details(data, options)
        data[:username] = options[:username]
        data[:email]    = options[:email] if options[:email]
      end


      def build_xml_body
        Nokogiri::XML::Builder.new do |xml|
          yield xml
          ns = xml.doc.root.add_namespace_definition('mns1', 'http://webservices.webpayserver.transbank.com/')
          xml.doc.root.namespace = ns
        end
      end

      # Init inscription data requires:
      #
      #   :username
      #   :email
      #   :return_url
      #
      def build_init_inscription_body(data)
        build_xml_body do |xml|
          xml.initInscription do
            xml.arg0 do
              xml.email       data[:email]
              xml.responseURL data[:return_url]
              xml.username    data[:username]
            end
          end
        end
      end

      # Finish inscription request requires:
      #
      #   :token
      #
      def build_finish_inscription_body(data)
        build_xml_body do |xml|
          xml.finishInscription do
            xml.arg0 do
              xml.token data[:token]
            end
          end
        end
      end

      # Remove the user from transbank, takes the fields:
      #
      #   :token    => Given when inscription created
      #   :username => Users human name, not necessarily login
      #
      def build_remove_user_body(data)
        build_xml_body do |xml|
          xml.removeUser do
            xml.arg0 do
              xml.tbkUser  data[:token]
              xml.username data[:username]
            end
          end
        end
      end

      # Request requires:
      #
      #   :username
      #   :amount
      #   :order_id
      #
      # Taken from configuration:
      #
      #   :merchant_id
      #
      def build_authorize_body(data)
        build_xml_body do |xml|
          xml.authorize do
            xml.arg0 do
              xml.amount   data[:amount]
              xml.buyOrder data[:order_id]
              xml.tbkUser  data[:merchant_id]
              xml.username data[:username]
            end
          end
        end
      end

      # Requires:
      #
      #  :order_id
      #
      def build_reverse_body(data)
        build_xml_body do |xml|
          xml.reverse do
            xml.arg0 do
              xml.buyorder data[:order_id]
            end
          end
        end
      end

      # Return an OpenSSL X509 certificate ready to use
      def certificate
        @_certificate ||= OpenSSL::X509::Certificate.new(@options[:certificate])
      end

      def private_key
        @_private_key ||= OpenSSL::PKey::RSA.new(@options[:private_key])
      end

      def signature_for_body(body)
        sha1 = OpenSSL::Digest::SHA1.new
        Base64.strict_encode64(
          private_key.sign(sha1, body.doc.canonicalize)
        )
      end

      def digest_for_body(body)
        sha1 = OpenSSL::Digest::SHA1.new
        Base64.strict_encode64(sha1.digest(body.doc.canonicalize))
      end

      def build_soap_request(body)
        namespaces = {
          'xmlns:soap' => 'http://schemas.xmlsoap.org/soap/envelope/',
          'xmlns:xsd'  => "http://www.w3.org/2001/XMLSchema",
          'xmlns:xsi'  => "http://www.w3.org/2001/XMLSchema-instance",
          'xmlns:wsse' => "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"
        }

        xml = Nokogiri::XML::Builder.new do |xml|
          xml.Envelope(namespaces) do
            # Add namespace to root
            ns = xml.parent.namespace_definitions.find{|ns|ns.prefix=="soap"}
            xml.doc.root.namespace = ns

            # Add the header
            xml['soap'].Header do
              xml['wsse'].Security('soap:mustUnderstand' => '1') do

                xml.Signature('xmlns' => "http://www.w3.org/2000/09/xmldsig#") do |xml|

                  xml.SignedInfo do |xml|
                    xml.CanonicalizationMethod('Algorithm' => 'http://www.w3.org/2001/10/xml-exc-c14n#')
                    xml.SignatureMethod('Algorithm' => "http://www.w3.org/2000/09/xmldsig#rsa-sha1")
                    xml.Reference do |xml|
                      xml.Transforms do
                        xml.Transform('Algorithm' => "http://www.w3.org/2001/10/xml-exc-c14n#")
                      end

                      xml.DigestMethod('Algorithm' => "http://www.w3.org/2000/09/xmldsig#sha1")
                      xml.DigestValue digest_for_body(body)
                    end
                  end
                  xml.SignatureValue signature_for_body(body)

                  xml.KeyInfo('xmlns' => "http://www.w3.org/2000/09/xmldsig#") do
                    xml['wsse'].SecurityTokenReference do
                      xml['wsse'].Reference(:URI => "#x509data")
                    end
                    xml.KeyValue do
                      xml.RSAKeyValue do
                        xml.Modulus  Base64.strict_encode64(private_key.n.to_s)
                        xml.Exponent Base64.strict_encode64(private_key.e.to_s)
                      end
                    end
                    xml.X509Data(:Id => "x509data") do
                      xml.X509IssuerSerial do
                        xml.X509IssuerName   certificate.issuer
                        xml.X509SerialNumber certificate.serial
                      end
                      xml.X509SubjectName certificate.subject
                      xml.X509Certificate certificate.to_pem.gsub("\n", "").gsub(/-----(BEGIN|END) CERTIFICATE-----/, "")
                    end
                  end # KeyInfo
                end # Signature
              end # Security
            end # Header

            # Add the actual payload
            xml['soap'].Body do
              xml << body.doc.root.to_s
            end
          end
        end

        xml
      end

      def url
        live_url
      end

      def commit(method, data)
        method = "build_#{method}_body"
        body = send(method, data)
        xml = build_soap_request(body)
        puts xml.to_xml
        #parse ssl_post(url, xml.to_xml)
      end

      # Parse the incoming SOAP response.
      def parse(xml)
        reply = {}

        puts xml

        #doc = Nokogiri::XML.parse(xml)

        #body = doc.xpath("//Body")

        #return reply
      end

    end
  end
end

