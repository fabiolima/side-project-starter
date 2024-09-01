class Ahoy::Store < Ahoy::DatabaseStore
end

# Ahoy.server_side_visits = :when_needed

# set to true for JavaScript tracking
Ahoy.api = false

# set to true for geocoding (and add the geocoder gem to your Gemfile)
# we recommend configuring local geocoding as well
# see https://github.com/ankane/ahoy#geocoding
Ahoy.geocode = false

Ahoy.exclude_method = lambda do |controller, request|
  def exclude_page?(current_path)
    [
      "/admin/dashboard",
      "/admins",
      "/users",
      "/app/dashboard"
    ].any? { |path| current_path.include? path }
  end

  def invalid_referrer?(referrer)
    return false if Rails.env == "test"
    referrer.nil?
  end

  exclude_page?(request.referrer || request.path) || invalid_referrer?(request.referrer)
end
