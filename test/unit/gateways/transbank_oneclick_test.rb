require 'test_helper'

class TransbankOneclickTest < Test::Unit::TestCase
  def setup
    @gateway = TransbankOneclickGateway.new(
                 :private_key => sample_key,
                 :certificate => sample_cert
               )

    @amount = 1000 # this is 10 CLP!

    @init_token = "e97096ec877f7ecad37af04d9c58923b611913ce4cf0af774bd769058eeafd05"

    # Note that the user token includes the username in Base64!
    @user_token = "92360d50-0c23-4040-a734-fc5f33b97791|U2Ft"

    @options = {
      :order_id => '20130123122904961'
    }
  end

  def test_init_inscription
    # Note to self, if this signature does not match, the request is different than expected!
    @gateway.expects(:ssl_post).with(
      anything,
      all_of(
        includes("<ds:SignatureValue>kRb3oJXQwmB303qWqdgxpsLAjxeCW8CAZKOB8CeecRO9XVh8KXQgSRke2hAOcvmqScQZqE7WVlp4cL5NhEBooTUddz6H9WO+EhRdy08Rx5q4u+OElJeMLNd8PzuSJnr7TCWvqXkQsoyJS4OiUGieUSX/bT6WKyETBW9r861Ea652a3lBMyr2nyvucqpbpq7ZIz2AZoLNoJhYaz5ztfJoO8SQ62+hht5ADn7c2LG6UR6dTuJgRNMfQggKyL1I9smno988YLPr3Z41NlQnzHxWvsQ5EWF67hCWkwbYGc6C7twS18skhchLVibTJMCFW6LzNusDquB/Z0xZUfm0mra66A==</ds:SignatureValue>"),
        includes("<email>sam@gmail.com</email>"),
        includes("<responseURL>http://localhost:3000</responseURL>"),
        includes("<username>Sam</username>")
      )
    ).returns(successful_init_inscription_response)

    assert response = @gateway.init_inscription(:username => "Sam", :email => "sam@gmail.com", :return_url => "http://localhost:3000")
    assert_success response
    assert_equal @init_token, response.token
    assert response.test?
  end

  def test_finish_inscription
    @gateway.expects(:ssl_post).with(
      anything,
      all_of(
        includes("<ds:SignatureValue>x9s1+GoY7gjMJGFb5svFg3x8FWBGxri0EGqzXDhZJtocTiahV2SC/RhUtL3lYzbs/dTe4E68F79uS2Dalr9lKH2zwCBg262Ui62sTbyNrDqp/RuKTP62MTDlzt6taC+AbUz91iCSl8jUcyZyvnq5sDuqJj5PKtal2Hu8pnTp9ZTNGSl0bt/Ov/R0WISB6cM5D2XweECKlyQUDJagBvtq+3Oo+OJLjFeO8Grh33LTusrPaXv2ehlr6yG2Dms3l4gS9+grhFQcS7AuX/ldQRuN6ktIxg9F9dJxAq7DW2V0aIpUcLTCd7itC4Pr+daerK7Xlvn/CdwqMOSUxaZfkGAvmQ==</ds:SignatureValue>"),
        includes("<token>e97096ec877f7ecad37af04d9c58923b611913ce4cf0af774bd769058eeafd05</token>")
      )
    ).returns(successful_finish_inscription_response)

    assert response = @gateway.finish_inscription(@init_token, :username => "Sam")
    assert_success response
    assert_equal @user_token, response.token
    assert_equal "1679", response.credit_card_last_4
    assert_equal :visa, response.credit_card_type
    assert response.test?
  end

  def test_remove_user
    @gateway.expects(:ssl_post).with(
      anything,
      all_of(
        includes("<ds:SignatureValue>qqERI6oevWkU/tjHZyH6R2aQDAGFQy8QHdS7Hk3DFaqxifzimUIQ+i8+WjDxC7ino9LSTFlijzHp/KasnfoGe6mg1u9qa256bVdJ3zFUlq90JF7xFtnP95mQYtxPYoUrJE0FGpqYUxPdu08NOtkShR4zSYC0W9HhDdp6he+v90YdcFliouybsTI6nqjhaEPBR/wTtbSILAPkj4Sh+Wm1j6dvzIpOpiBPkhs4fAm0VExO8MLMguYAEuGc2OURcRMs0ZjSdGhk2DafZ0narrr7Qx7NtdhBcuUWeq6jd/ab0tyx44+SpBbSEYLRg2ap7cBtp+FsNBIxKxM9B2cypvcu4Q==</ds:SignatureValue>"),
        includes("<tbkUser>92360d50-0c23-4040-a734-fc5f33b97791</tbkUser>"),
        includes("<username>Sam</username>")
      )
    ).returns(successful_remove_user_response)

    assert response = @gateway.remove_user(@user_token)
    assert_success response
    assert response.test?
  end

  def test_successful_purchase
    @gateway.expects(:ssl_post).with(
      anything,
      all_of(
        includes("<ds:SignatureValue>R6bmQ9OxAxSeYXrXkCtM1rKLFT3WsKstNoAey9nXFSqCvFGkH8QAgRnzBgdrKVcGfWohYkZVozeZ2+CgPwo+8/tGFneWGlcJ22ppntulVk3FseBNWYEhVRwylNfcemVfhra8rCNkGZ2JWIZ5QWbL+zb4DMdHZYcLJrt3lmyOQP10581hrEUWcbCMmn05KqgMdv54+GZVauIwot1OpPxk0AQeug3fVfq1opHoFobCPov3DlXbXv/k2938tM3Cd2yE7cDVCDn5AWlIVV6w7nKs9nVRr3tEKm121YSZJaQiVH1k6EkCJMoXicybTgWh7XFn6LeMKT9GRCH1Fk9vnRNGmQ==</ds:SignatureValue>"),
        includes("<amount>10.00</amount>"),
        includes("<buyOrder>20130123122904961</buyOrder>"),
        includes("<tbkUser>92360d50-0c23-4040-a734-fc5f33b97791</tbkUser>"),
        includes("<username>Sam</username>")
      )
    ).returns(successful_purchase_response)

    assert response = @gateway.purchase(@amount, @user_token, @options)
    assert_success response
    assert_equal @options[:order_id], response.authorization
    assert response.test?
  end

  def test_unsuccessful_purchase
    @gateway.expects(:ssl_post).returns(declined_purchase_response)

    assert response = @gateway.purchase(@amount, @user_token)

    assert_failure response
    assert_equal "Maximum payment amount exceeded", response.message
    assert response.test?
  end

  def test_successful_refund

  end

  #def test_unsuccessful_request
  #  @gateway.expects(:ssl_post).returns(failed_purchase_response)

  #  assert response = @gateway.purchase(@amount, @credit_card, @options)
  #  assert_failure response
  #  assert response.test?
  #end

  private

  def successful_init_inscription_response
    "<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Header><wsse:Security xmlns:wsse=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd\" xmlns:wsu=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd\" soap:mustUnderstand=\"1\"><ds:Signature xmlns:ds=\"http://www.w3.org/2000/09/xmldsig#\" Id=\"SIG-60\"><ds:SignedInfo><ds:CanonicalizationMethod Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\"><ec:InclusiveNamespaces xmlns:ec=\"http://www.w3.org/2001/10/xml-exc-c14n#\" PrefixList=\"soap\"/></ds:CanonicalizationMethod><ds:SignatureMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#rsa-sha1\"/><ds:Reference URI=\"#id-59\"><ds:Transforms><ds:Transform Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\"><ec:InclusiveNamespaces xmlns:ec=\"http://www.w3.org/2001/10/xml-exc-c14n#\" PrefixList=\"\"/></ds:Transform></ds:Transforms><ds:DigestMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#sha1\"/><ds:DigestValue>8cmwWRN5iCqacfLlFmviQzcRV5A=</ds:DigestValue></ds:Reference></ds:SignedInfo><ds:SignatureValue>UZlcwvr07VBXTE8qhRNhLpvMHnpJcfqtEzKhMMi8eGkKwlg1HqKBpaMikf098Mfy/M+t5wcFt52i\nFsSDCjNy5m0uOgmYvAvpvbroSxiXy76Y/wHWxsWzL1e1LbAgUSN4yCFeOz4UzMgII2VSh9E0EFhe\n1gfkZ7FR7pCoLomQv6Q=</ds:SignatureValue><ds:KeyInfo Id=\"KI-5F7FD9365593894E07135470842303889\"><wsse:SecurityTokenReference wsu:Id=\"STR-5F7FD9365593894E07135470842303890\"><ds:X509Data><ds:X509IssuerSerial><ds:X509IssuerName>CN=10,OU=DCR,O=Transbank,L=Santiago,ST=CL,C=CL</ds:X509IssuerName><ds:X509SerialNumber>1345478488</ds:X509SerialNumber></ds:X509IssuerSerial></ds:X509Data></wsse:SecurityTokenReference></ds:KeyInfo></ds:Signature></wsse:Security></soap:Header><soap:Body xmlns:wsu=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd\" wsu:Id=\"id-59\"><ns2:initInscriptionResponse xmlns:ns2=\"http://webservices.webpayserver.transbank.com/\"><return><token>e97096ec877f7ecad37af04d9c58923b611913ce4cf0af774bd769058eeafd05</token></return></ns2:initInscriptionResponse></soap:Body></soap:Envelope>"
  end

  def successful_finish_inscription_response
    "<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Header><wsse:Security xmlns:wsse=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd\" xmlns:wsu=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd\" soap:mustUnderstand=\"1\"><ds:Signature xmlns:ds=\"http://www.w3.org/2000/09/xmldsig#\" Id=\"SIG-54\"><ds:SignedInfo><ds:CanonicalizationMethod Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\"><ec:InclusiveNamespaces xmlns:ec=\"http://www.w3.org/2001/10/xml-exc-c14n#\" PrefixList=\"soap\"/></ds:CanonicalizationMethod><ds:SignatureMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#rsa-sha1\"/><ds:Reference URI=\"#id-53\"><ds:Transforms><ds:Transform Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\"><ec:InclusiveNamespaces xmlns:ec=\"http://www.w3.org/2001/10/xml-exc-c14n#\" PrefixList=\"\"/></ds:Transform></ds:Transforms><ds:DigestMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#sha1\"/><ds:DigestValue>eKD6OcQyErDMypXKlyHaveinvN4=</ds:DigestValue></ds:Reference></ds:SignedInfo><ds:SignatureValue>CwAg3jAXeWMdqnXHwe4IofM6ai6mAn8CGIesNzSOnMCGvpUhyiVLJizQZnKx1r6AkFWC8ssd7B7p\nCXKLYGEB0V4bwfo00Fj5AbmlA+gtwgPDVtOqAoAz4Bmc2lCfSP4jVqw8u0FpZRaGOEQwvetX7bfn\nAt9q8FyKU9Sr0J4Zj5I=</ds:SignatureValue><ds:KeyInfo Id=\"KI-6A7DF34F79595E3A89135472510757780\"><wsse:SecurityTokenReference wsu:Id=\"STR-6A7DF34F79595E3A89135472510757781\"><ds:X509Data><ds:X509IssuerSerial><ds:X509IssuerName>CN=10,OU=DCR,O=Transbank,L=Santiago,ST=CL,C=CL</ds:X509IssuerName><ds:X509SerialNumber>1345478488</ds:X509SerialNumber></ds:X509IssuerSerial></ds:X509Data></wsse:SecurityTokenReference></ds:KeyInfo></ds:Signature></wsse:Security></soap:Header><soap:Body xmlns:wsu=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd\" wsu:Id=\"id-53\"><ns2:finishInscriptionResponse xmlns:ns2=\"http://webservices.webpayserver.transbank.com/\"><return><authCode>133141</authCode><creditCardType>Visa</creditCardType><last4CardDigits>1679</last4CardDigits><responseCode>0</responseCode><tbkUser>92360d50-0c23-4040-a734-fc5f33b97791</tbkUser></return></ns2:finishInscriptionResponse></soap:Body></soap:Envelope>"
  end

  def failed_finish_inscription_response
    "<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><soap:Fault><faultcode>soap:Server</faultcode><faultstring>Can't initialize user inscription</faultstring></soap:Fault></soap:Body></soap:Envelope>"
  end

  def successful_remove_user_response
    "<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Header><wsse:Security xmlns:wsse=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd\" xmlns:wsu=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd\" soap:mustUnderstand=\"1\"><ds:Signature xmlns:ds=\"http://www.w3.org/2000/09/xmldsig#\" Id=\"SIG-64\"><ds:SignedInfo><ds:CanonicalizationMethod Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\"><ec:InclusiveNamespaces xmlns:ec=\"http://www.w3.org/2001/10/xml-exc-c14n#\" PrefixList=\"soap\"/></ds:CanonicalizationMethod><ds:SignatureMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#rsa-sha1\"/><ds:Reference URI=\"#id-63\"><ds:Transforms><ds:Transform Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\"><ec:InclusiveNamespaces xmlns:ec=\"http://www.w3.org/2001/10/xml-exc-c14n#\" PrefixList=\"\"/></ds:Transform></ds:Transforms><ds:DigestMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#sha1\"/><ds:DigestValue>zFpor39d2WgYMyOHvKBa4sN0ZMM=</ds:DigestValue></ds:Reference></ds:SignedInfo><ds:SignatureValue>VFTrmJCv2qRQLMyErFeQQxP7UXFsKEVqQQIQ8D57dWKJHE5nMvIEN1mxeD3ygZJTtCSewhqI5X7R\nn0rwpkH33+XNfDXqfKdzGOUMnJjf+26YeNa6RhCLugfZUeX8wLJqBnRXaXT/djk5YXPyf/S+H0fg\nyLbcaMomvTfW2FQhbDk=</ds:SignatureValue><ds:KeyInfo Id=\"KI-6A7DF34F79595E3A89135487722567095\"><wsse:SecurityTokenReference wsu:Id=\"STR-6A7DF34F79595E3A89135487722567096\"><ds:X509Data><ds:X509IssuerSerial><ds:X509IssuerName>CN=10,OU=DCR,O=Transbank,L=Santiago,ST=CL,C=CL</ds:X509IssuerName><ds:X509SerialNumber>1345478488</ds:X509SerialNumber></ds:X509IssuerSerial></ds:X509Data></wsse:SecurityTokenReference></ds:KeyInfo></ds:Signature></wsse:Security></soap:Header><soap:Body xmlns:wsu=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd\" wsu:Id=\"id-63\"><ns2:removeUserResponse xmlns:ns2=\"http://webservices.webpayserver.transbank.com/\"><return>true</return></ns2:removeUserResponse></soap:Body></soap:Envelope>"
  end

  # Place raw successful response from gateway here
  def successful_purchase_response
    "<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Header><wsse:Security xmlns:wsse=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd\" xmlns:wsu=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd\" soap:mustUnderstand=\"1\"><ds:Signature xmlns:ds=\"http://www.w3.org/2000/09/xmldsig#\" Id=\"SIG-66\"><ds:SignedInfo><ds:CanonicalizationMethod Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\"><ec:InclusiveNamespaces xmlns:ec=\"http://www.w3.org/2001/10/xml-exc-c14n#\" PrefixList=\"soap\"/></ds:CanonicalizationMethod><ds:SignatureMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#rsa-sha1\"/><ds:Reference URI=\"#id-65\"><ds:Transforms><ds:Transform Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\"><ec:InclusiveNamespaces xmlns:ec=\"http://www.w3.org/2001/10/xml-exc-c14n#\" PrefixList=\"\"/></ds:Transform></ds:Transforms><ds:DigestMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#sha1\"/><ds:DigestValue>VOU1MLsucwZprhd5Z0xxefB8kQc=</ds:DigestValue></ds:Reference></ds:SignedInfo><ds:SignatureValue>BMWAsqXm9muD26Q3yhaogJks3Aet54YEdcD2++mWdrJAu5tDiOgIgbELqAnVDIIquyU6NQTYaC9a\nbKqEcaHV0ID73qCYTfbqn79Qm2hkRxU9CoQdxsqWB3Y5CTbnxtpkMf5kEq6NYqLEuFc5YvV4Icv5\n40p+o8GbLbMiobwSujQ=</ds:SignatureValue><ds:KeyInfo Id=\"KI-8AACDBC27FF326E879135473155938998\"><wsse:SecurityTokenReference wsu:Id=\"STR-8AACDBC27FF326E879135473155938999\"><ds:X509Data><ds:X509IssuerSerial><ds:X509IssuerName>CN=10,OU=DCR,O=Transbank,L=Santiago,ST=CL,C=CL</ds:X509IssuerName><ds:X509SerialNumber>1345478488</ds:X509SerialNumber></ds:X509IssuerSerial></ds:X509Data></wsse:SecurityTokenReference></ds:KeyInfo></ds:Signature></wsse:Security></soap:Header><soap:Body xmlns:wsu=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd\" wsu:Id=\"id-65\"><ns2:authorizeResponse xmlns:ns2=\"http://webservices.webpayserver.transbank.com/\"><return><authorizationCode>151918</authorizationCode><creditCardType>Visa</creditCardType><last4CardDigits>1679</last4CardDigits><responseCode>0</responseCode><transactionId>594283</transactionId></return></ns2:authorizeResponse></soap:Body></soap:Envelope>"
  end

  # Place raw failed response from gateway here
  def declined_purchase_response
    "<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Header><wsse:Security xmlns:wsse=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd\" xmlns:wsu=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd\" soap:mustUnderstand=\"1\"><ds:Signature xmlns:ds=\"http://www.w3.org/2000/09/xmldsig#\" Id=\"SIG-58\"><ds:SignedInfo><ds:CanonicalizationMethod Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\"><ec:InclusiveNamespaces xmlns:ec=\"http://www.w3.org/2001/10/xml-exc-c14n#\" PrefixList=\"soap\"/></ds:CanonicalizationMethod><ds:SignatureMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#rsa-sha1\"/><ds:Reference URI=\"#id-57\"><ds:Transforms><ds:Transform Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\"><ec:InclusiveNamespaces xmlns:ec=\"http://www.w3.org/2001/10/xml-exc-c14n#\" PrefixList=\"\"/></ds:Transform></ds:Transforms><ds:DigestMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#sha1\"/><ds:DigestValue>ix2r/FUp6n/MOwDKWG6uQ1iQj24=</ds:DigestValue></ds:Reference></ds:SignedInfo><ds:SignatureValue>M8ABWXA8xN/bFxOacKaXs4oL2fLi+6mqVCRUSiaol/c3AIVxcEwJPGOKABkLg0oDZ+10L/yeeiqy\n1+7WCN4wFoM8tpODI6cM9s9hDPxjikBr+/Ijgb+RaaA8LrX+YnelkPhXTPTVxFFviqbL5m++mppp\ntgqQD+jgkZYgD5JRBl0=</ds:SignatureValue><ds:KeyInfo Id=\"KI-6A7DF34F79595E3A89135473070489086\"><wsse:SecurityTokenReference wsu:Id=\"STR-6A7DF34F79595E3A89135473070489087\"><ds:X509Data><ds:X509IssuerSerial><ds:X509IssuerName>CN=10,OU=DCR,O=Transbank,L=Santiago,ST=CL,C=CL</ds:X509IssuerName><ds:X509SerialNumber>1345478488</ds:X509SerialNumber></ds:X509IssuerSerial></ds:X509Data></wsse:SecurityTokenReference></ds:KeyInfo></ds:Signature></wsse:Security></soap:Header><soap:Body xmlns:wsu=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd\" wsu:Id=\"id-57\"><ns2:authorizeResponse xmlns:ns2=\"http://webservices.webpayserver.transbank.com/\"><return><creditCardType>Visa</creditCardType><last4CardDigits>1679</last4CardDigits><responseCode>-98</responseCode><transactionId>594273</transactionId></return></ns2:authorizeResponse></soap:Body></soap:Envelope>"
  end

  def successful_refund_response
    "<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Header><wsse:Security xmlns:wsse=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd\" xmlns:wsu=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd\" soap:mustUnderstand=\"1\"><ds:Signature xmlns:ds=\"http://www.w3.org/2000/09/xmldsig#\" Id=\"SIG-74\"><ds:SignedInfo><ds:CanonicalizationMethod Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\"><ec:InclusiveNamespaces xmlns:ec=\"http://www.w3.org/2001/10/xml-exc-c14n#\" PrefixList=\"soap\"/></ds:CanonicalizationMethod><ds:SignatureMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#rsa-sha1\"/><ds:Reference URI=\"#id-73\"><ds:Transforms><ds:Transform Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\"><ec:InclusiveNamespaces xmlns:ec=\"http://www.w3.org/2001/10/xml-exc-c14n#\" PrefixList=\"\"/></ds:Transform></ds:Transforms><ds:DigestMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#sha1\"/><ds:DigestValue>oe3mVX+IFCoGxb/pZyDwdBJr/Rg=</ds:DigestValue></ds:Reference></ds:SignedInfo><ds:SignatureValue>dpfn4kA0koiSyMeSO454e3S2PEsYzjm9tbldcJTEL+HkNOfqwr2pnCF2louWWx6T5BV55Z2OmtL6\nRMP35CtDXNBp/HNTa7kJYdcs/5S5msaVIombZYD1zSF038BDgtGMRy1qU/rjZws4FXB4v3//Va6s\n6G7ZQKBIQSEd90T1ulE=</ds:SignatureValue><ds:KeyInfo Id=\"KI-8AACDBC27FF326E8791354737065816110\"><wsse:SecurityTokenReference wsu:Id=\"STR-8AACDBC27FF326E8791354737065816111\"><ds:X509Data><ds:X509IssuerSerial><ds:X509IssuerName>CN=10,OU=DCR,O=Transbank,L=Santiago,ST=CL,C=CL</ds:X509IssuerName><ds:X509SerialNumber>1345478488</ds:X509SerialNumber></ds:X509IssuerSerial></ds:X509Data></wsse:SecurityTokenReference></ds:KeyInfo></ds:Signature></wsse:Security></soap:Header><soap:Body xmlns:wsu=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd\" wsu:Id=\"id-73\"><ns2:reverseResponse xmlns:ns2=\"http://webservices.webpayserver.transbank.com/\"><return>true</return></ns2:reverseResponse></soap:Body></soap:Envelope>"
  end

  def failed_refund_resposnse
    "<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Header><wsse:Security xmlns:wsse=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd\" xmlns:wsu=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd\" soap:mustUnderstand=\"1\"><ds:Signature xmlns:ds=\"http://www.w3.org/2000/09/xmldsig#\" Id=\"SIG-60\"><ds:SignedInfo><ds:CanonicalizationMethod Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\"><ec:InclusiveNamespaces xmlns:ec=\"http://www.w3.org/2001/10/xml-exc-c14n#\" PrefixList=\"soap\"/></ds:CanonicalizationMethod><ds:SignatureMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#rsa-sha1\"/><ds:Reference URI=\"#id-59\"><ds:Transforms><ds:Transform Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\"><ec:InclusiveNamespaces xmlns:ec=\"http://www.w3.org/2001/10/xml-exc-c14n#\" PrefixList=\"\"/></ds:Transform></ds:Transforms><ds:DigestMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#sha1\"/><ds:DigestValue>5/aAwJ1ChJvaPMWJghZLDtZcsEo=</ds:DigestValue></ds:Reference></ds:SignedInfo><ds:SignatureValue>TFL02JpRlIPZMTTFHyjKGtLfGxjw1sXRfTwxFfegvtKdUba0geS1dSZn/AI3ezrUAgdiHuMa2RsO\n67G3bOjChZ7WeWq6XACJV3FqYfXqykw8iY8ffyVzlEqyjLccloeWJEjt6JJ6JJMjCpcCgqcVEVnT\nSx3E0TXICIgUcJHnfUA=</ds:SignatureValue><ds:KeyInfo Id=\"KI-6A7DF34F79595E3A89135473372697089\"><wsse:SecurityTokenReference wsu:Id=\"STR-6A7DF34F79595E3A89135473372697090\"><ds:X509Data><ds:X509IssuerSerial><ds:X509IssuerName>CN=10,OU=DCR,O=Transbank,L=Santiago,ST=CL,C=CL</ds:X509IssuerName><ds:X509SerialNumber>1345478488</ds:X509SerialNumber></ds:X509IssuerSerial></ds:X509Data></wsse:SecurityTokenReference></ds:KeyInfo></ds:Signature></wsse:Security></soap:Header><soap:Body xmlns:wsu=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd\" wsu:Id=\"id-59\"><ns2:reverseResponse xmlns:ns2=\"http://webservices.webpayserver.transbank.com/\"><return>false</return></ns2:reverseResponse></soap:Body></soap:Envelope>"
  end



  # Sample Private Key, this is not usable with Transbank!
  def sample_key
"-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAyBg7ZisBRqy9iuqd8KvK12JLWrabe3yL+df/jJcuxEpW6Kky
S8sez7O1dAvCcGWIyF0L4OWoTFZEXyUqdYBc+099G0D1S4UJ8gz30W9sZdD6rwlJ
Hmv1EG62UHGk8GgzJmepcCQwaz8y8t5eRwqqzDgslsj15WsJuVNmoMP0IWTjkGE0
PyGJvSs5YDUBnOelh2MyJiRvcOrpOIFMO9pc0xUAeIBbJCNwBuOmxeVVo30Ve+ZV
uFVPhJaLWW17CIYcaCoXkzXa5yVWw/Uz3W/N1TDtXLnqQdfnqU44IjQd+P5FrBfn
c7RQKL0ra8l4x6Q4qhWjBRqGJFutYZ+P/rtkyQIDAQABAoIBAFb9kfVdBPUA7HaU
gY28Yjc5WKFbekU5ZHF+Ym9w2rgjyZzk0iT5ba/G5UBKTIIo4kqZiSyBK6Xka10h
/0+OOt5XNIDAwOPQNv6wfJzk4C9zp0iptMwxCx3VxBU9EwQhiPtNXfCPCy3VEAVe
f4ZLMO4QDfKP87eFzXhwtdF235AUUv+bjkLKnJi+MshdR3j7jYOwOLOsb5m44aHw
kThTDkulzHjR3V9qFO96Ed/MAh+8SOmOznpRulXS5/eiqWjdRj4IZ+iB3XZsXfB4
39Eg42QCdWNwcwrJhji+R1VEMRLxlmczG8X8PIwyarXnLg/sxo3Wwv3dLvNIjeXq
R9lkufECgYEA9vlXr6Z6KZheILgnFoARWvocTPT9W5fAj73ganL/qMsCA8yWWkpD
x0PyMSlVo/xE37YMabQCIQQ75cKoDvi1+HDFpGJi/LpkDcfAqj3Y++jNpAGXrBXe
fppFfPHSJ7AE7sp3GDYHg3Fe4B4PX/bg6g4G6IIwEAPcGfT1DSPqd+8CgYEAz2hK
1wV41sBS8NkTay6i1rludiyvlXbUWeKMAiiPUE9XmGAq7VL+/uU9IwE/fqgh4rL8
PoZaix9ghl7KA1ZNlC1QfGIU1fpZz5KWpqUU5H8KwQTTVRu5baN/VQ1GDTj08U7f
NeAfkanBpFLr1oziA2+NVmCORKtf5vZsEVLQdscCgYAknkGvDHruceX66fL5thFc
sNrDWku6adymM1vzzIs1hqwMzie4yWwVPnDJczx8bOn1VXOvtH3gUVVkMqFiXuP0
KxxSzDerCyPMm0Jou3TRnOnomEfZvwBXOx50cRJcyg9hLGnOECy7A3MyvaI/80XT
zjKeBLeFmFzpCFXRFfMsxwKBgQCNzjidGtiru4L5uPFV7uTW+qFTmunRvxUg/4vK
TgDuX9D8FYREDuLZU9KhBFFtP3crkER2W1W8mQ9dz6E+9trD3NeSs1ybkDenfAoU
lfna4CFyJuJ25iW5mHeOpyymDbMq6Uojg8ERzobe2vL0Fg7RWou/6vRabvF68DCj
B4QQMQKBgEtObgMBPAl3jEM79kO4lO8maO6hn5QCPkCr+bOX5MpIpnV1kdVhSZl3
EmzgnbXs/wZh7Cm2oQM2J8df5osVsPJ7rBjAwA0HBhU3lm2hTlfknjJayum+xYkM
FwLRWvWDwqpjXg5e1naWV7si4JF+y0l/cvK1M0Ibh/KJMhY4kju7
-----END RSA PRIVATE KEY-----"
  end

  # Sample Certificate, not usable with Transbank
  def sample_cert
"-----BEGIN CERTIFICATE-----
MIIDWjCCAkICCQC2BfBLLivHkzANBgkqhkiG9w0BAQUFADBvMQswCQYDVQQGEwJD
TDETMBEGA1UECBMKU29tZS1TdGF0ZTERMA8GA1UEBxMIU0FOVElBR08xITAfBgNV
BAoTGEludGVybmV0IFdpZGdpdHMgUHR5IEx0ZDEVMBMGA1UEAxMMNTk3MDEwMDAw
MDAzMB4XDTEyMTIwNTEyMTAwNFoXDTIyMTIwMzEyMTAwNFowbzELMAkGA1UEBhMC
Q0wxEzARBgNVBAgTClNvbWUtU3RhdGUxETAPBgNVBAcTCFNBTlRJQUdPMSEwHwYD
VQQKExhJbnRlcm5ldCBXaWRnaXRzIFB0eSBMdGQxFTATBgNVBAMTDDU5NzAxMDAw
MDAwMzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMgYO2YrAUasvYrq
nfCrytdiS1q2m3t8i/nX/4yXLsRKVuipMkvLHs+ztXQLwnBliMhdC+DlqExWRF8l
KnWAXPtPfRtA9UuFCfIM99FvbGXQ+q8JSR5r9RButlBxpPBoMyZnqXAkMGs/MvLe
XkcKqsw4LJbI9eVrCblTZqDD9CFk45BhND8hib0rOWA1AZznpYdjMiYkb3Dq6TiB
TDvaXNMVAHiAWyQjcAbjpsXlVaN9FXvmVbhVT4SWi1ltewiGHGgqF5M12uclVsP1
M91vzdUw7Vy56kHX56lOOCI0Hfj+RawX53O0UCi9K2vJeMekOKoVowUahiRbrWGf
j/67ZMkCAwEAATANBgkqhkiG9w0BAQUFAAOCAQEAopUJVl/0y4gQrZfw2SGpsb8V
rjnsIdnJvQCdZRJMg5Uh5FOcwHkV+jK5c82oxnLxfnqXQC4RXfFjfvNRxBg0hfVs
gWubyd6/h99YpUvH3DiCT9rRskRdJaufNFHXTZASJIE1rc1Paka2YQQ02wGxYAey
soQc637e8s8TSo8nY+84Q0ue61OYeUHDler6nkxoZuk5BhkyJRTI8NvB4zYe8Ano
o1wN9+egngfyMJzhyxOT+fARWxkkxPwW1orvNKpkZ3X2kKxFmO7BDxT5YLScU17t
33d7gF4itaWzlmUjYac//6qbQ8zJFirGPUlNYWzjBqs4Rd3vSDX9coXOkAwvzw==
-----END CERTIFICATE-----"
  end
end
