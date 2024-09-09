# frozen_string_literal: true

require "test_helper"
require "minitest/mock"
require "mocha"

class UserSignInUpFlowTest < ActionDispatch::IntegrationTest
  setup do
    User.delete_all
  end

  test "should redirect to app dashboard after successfully sign up" do
    get new_user_registration_path
    assert_response :success

    mock_stripe_customer = Minitest::Mock.new
    mock_stripe_customer.expect(:create, true)

    Stripe::Customer.stub(:create, mock_stripe_customer) do
      post user_registration_path,
           params: { user: { email: "user@user.com", password: "123123", password_confirmation: "123123" } }
      follow_redirect!
      assert_equal app_dashboard_path, path
    end
  end

  test "should redirect to app dashboard after successfully sign in" do
    mock_stripe_customer = Minitest::Mock.new
    mock_stripe_customer.expect(:create, true)

    Stripe::Customer.stub(:create, mock_stripe_customer) do
      user = User.create!(email: "user@user.com", password: "123123", password_confirmation: "123123")
      get new_user_session_path
      assert_response :success

      post user_session_path, params: { user: { email: user.email, password: user.password } }
      follow_redirect!
      assert_equal app_dashboard_path, path
    end
  end
end
