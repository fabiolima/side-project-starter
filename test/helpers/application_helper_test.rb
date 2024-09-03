require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "active_link_to" do
    def current_page?(link)
      true
    end

    assert_equal(
      active_link_to("Home", root_path),
      link_to("Home", root_path, class: "font-bold underline")
    )

    assert_equal(
      active_link_to(root_path) { "Home" },
      link_to(root_path, class: "font-bold underline") { "Home" }
    )

    # override the default active classes
    assert_equal(
      active_link_to("Home", root_path, active_classes: "bg-rose-400", class: "foo"),
      link_to("Home", root_path, class: "foo bg-rose-400")
    )

    def current_page?(link)
      false
    end

    assert_equal(
      active_link_to("Home", root_path),
      link_to("Home", root_path)
    )

    assert_equal(
      active_link_to(root_path) { "Home" },
      link_to(root_path) { "Home" }
    )
  end

  test "path_from_url" do
    assert_equal(
      path_from_url("http://localhost:3000/"),
      "/"
    )

    assert_equal(
      path_from_url("http://localhost:3000/some/resource"),
      "/some/resource"
    )

    assert_equal(
      path_from_url("https://sub.domain.example.com/"),
      "/"
    )

    assert_equal(
      path_from_url("https://sub.domain.example.com/some/resource"),
      "/some/resource"
    )

    assert_equal(
      path_from_url("NON_URL_STRING"),
      "NON_URL_STRING"
    )

    assert_equal(
      path_from_url(nil),
      ""
    )
  end

  test "monthly_price" do
    assert_equal(monthly_price, Rails.application.credentials.dig(:stripe, :pricing, :monthly))
  end

  test "annual_price" do
    assert_equal(annual_price, Rails.application.credentials.dig(:stripe, :pricing, :annual))
  end
end
