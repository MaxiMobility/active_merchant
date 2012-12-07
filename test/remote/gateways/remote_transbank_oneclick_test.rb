require 'test_helper'

class RemoteTransbankOneclickTest < Test::Unit::TestCase


  def setup
    @gateway = TransbankOneclickGateway.new(fixtures(:transbank_oneclick))

    TransbankOneclickGateway.wiredump_device = File.open(File.join('/tmp', "dump.log"), "a+")
    TransbankOneclickGateway.wiredump_device.sync = true

    @amount = 100
    @credit_card = credit_card('4051885800381679')
    @declined_card = credit_card('4051885600446623')

    @options = {
      :order_id => '1',
      :billing_address => address,
      :description => 'Store Purchase'
    }
  end

  def test_init_inscription
    assert response = @gateway.init_inscription(:username => "Sam Lown", :email => "me@samlown.com", :return_url => "http://localhost:3000")
    assert_success response
    assert response.token
  end

#  def test_successful_purchase
#    assert response = @gateway.purchase(@amount, @credit_card, @options)
#    assert_success response
#    assert_equal 'REPLACE WITH SUCCESS MESSAGE', response.message
#  end
#
#  def test_unsuccessful_purchase
#    assert response = @gateway.purchase(@amount, @declined_card, @options)
#    assert_failure response
#    assert_equal 'REPLACE WITH FAILED PURCHASE MESSAGE', response.message
#  end
#
#  def test_authorize_and_capture
#    amount = @amount
#    assert auth = @gateway.authorize(amount, @credit_card, @options)
#    assert_success auth
#    assert_equal 'Success', auth.message
#    assert auth.authorization
#    assert capture = @gateway.capture(amount, auth.authorization)
#    assert_success capture
#  end
#
#  def test_failed_capture
#    assert response = @gateway.capture(@amount, '')
#    assert_failure response
#    assert_equal 'REPLACE WITH GATEWAY FAILURE MESSAGE', response.message
#  end
#
#  def test_invalid_login
#    gateway = TransbankWebpayOneclickGateway.new(
#                :login => '',
#                :password => ''
#              )
#    assert response = gateway.purchase(@amount, @credit_card, @options)
#    assert_failure response
#    assert_equal 'REPLACE WITH FAILURE MESSAGE', response.message
#  end
end
