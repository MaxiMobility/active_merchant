require 'test_helper'

class RemoteTransbankOneclickTest < Test::Unit::TestCase


  def setup
    @gateway = TransbankOneclickGateway.new(fixtures(:transbank_oneclick))

    TransbankOneclickGateway.wiredump_device = File.open(File.join('/tmp', "oneclick.log"), "a+")
    TransbankOneclickGateway.wiredump_device.sync = true

    @amount = 60000
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

  # These tests cannot be run as a the confirmation screens must first be completed

  #def test_finish_and_remove_inscription
  #  assert response = @gateway.init_inscription(:username => "Sam Lown", :email => "me@samlown.com", :return_url => "http://localhost:3000")

  #  # Finish
  #  assert response = @gateway.finish_inscription(response.token, :username => "Sam Lown")
  #  assert_success response
  #  assert response.token

  #  # Remove
  #  assert response = @gateway.remove_user(response.token)
  #  assert_success response
  #end

  #def test_successful_purchase_and_refund
  #  # Inscription
  #  assert response = @gateway.init_inscription(:username => "Sam Lown", :email => "me@samlown.com", :return_url => "http://localhost:3000")
  #  assert response = @gateway.finish_inscription(response.token, :username => "Sam Lown")

  #  # Purchase
  #  assert response = @gateway.purchase(@amount, response.token)
  #  assert_success response
  #  assert response.authorization

  #  # Refund
  #  assert response = @gateway.refund(response.authorization)
  #  assert_success response
  #end

end
