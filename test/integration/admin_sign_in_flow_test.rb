# frozen_string_literal: true

require "test_helper"

class AdminSignInFlowTest < ActionDispatch::IntegrationTest
  setup do
    Admin.delete_all
  end

  test "should redirect to admin dashboard after successfully sign in" do
    admin = Admin.create!(email: "admin@admin.com", password: "123123", password_confirmation: "123123")

    get new_admin_session_path
    assert_response :success

    post admin_session_path, params: { admin: { email: admin.email, password: admin.password } }
    follow_redirect!
    assert_equal admin_dashboard_path, path
  end
end
