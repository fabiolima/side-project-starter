# frozen_string_literal: true

require "test_helper"

class AhoyVisitsFlow < ActionDispatch::IntegrationTest
  setup do
    Ahoy::Visit.delete_all
    Ahoy.track_bots = true
  end

  teardown do
    Ahoy.track_bots = false
  end

  test "should count homepage" do
    get root_path
    visits = Ahoy::Visit.count
    assert_equal(visits, 1)
  end

  test "should not count admin dashboard" do
    get admin_dashboard_path
    visits = Ahoy::Visit.count
    assert_equal(visits, 0)
  end

  test "should not count app dashboard" do
    get app_dashboard_path
    visits = Ahoy::Visit.count
    assert_equal(visits, 0)
  end

  test "do not count user sign in" do
    get new_user_session_path
    visits = Ahoy::Visit.count
    assert_equal(visits, 0)
  end

  test "do not count user new password" do
    get new_user_password_path
    visits = Ahoy::Visit.count
    assert_equal(visits, 0)
  end

  test "do not count user edit password" do
    get edit_user_password_path
    visits = Ahoy::Visit.count
    assert_equal(visits, 0)
  end

  test "do not count user sign up" do
    get new_user_registration_path
    visits = Ahoy::Visit.count
    assert_equal(visits, 0)
  end

  test "do not count admin sign in" do
    get new_admin_session_path
    visits = Ahoy::Visit.count
    assert_equal(visits, 0)
  end

  test "do not count admin new password" do
    get new_admin_password_path
    visits = Ahoy::Visit.count
    assert_equal(visits, 0)
  end

  test "do not count admin edit password" do
    get edit_admin_password_path
    visits = Ahoy::Visit.count
    assert_equal(visits, 0)
  end

  test "do not count admin sign up" do
    Admin.delete_all
    get new_admin_registration_path
    visits = Ahoy::Visit.count
    assert_equal(visits, 0)
  end
end
