require "test_helper"

class AdminSignUpFlowTest  < ActionDispatch::IntegrationTest
  setup do
    Admin.delete_all
  end

  test "should redirect to admin dashboard after successfully sign up" do
    get new_admin_registration_path
    assert_response :success

    post admin_registration_path, params: { admin: { email: "admin@admin.com", password: "123123", password_confirmation: "123123" } }
    follow_redirect!
    assert_equal admin_dashboard_path, path
  end

  test "should allow access to admin registration page if there is no admin" do
    get new_admin_registration_path
    assert_response :success
  end

  test "should redirect to sign in if there is an admin" do
    Admin.create!(email: "admin@admin.com", password: "123123", password_confirmation: "123123")

    get new_admin_registration_path
    assert_response :found
    assert_redirected_to new_admin_session_path
  end
end
