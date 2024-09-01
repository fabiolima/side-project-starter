class Admin::Dashboard::HomeController < ApplicationController
  include Pagy::Backend

  layout "administrator"
  before_action :authenticate_admin!

  def index
    @total_users ||= User.count
    @visits = Ahoy::Visit
      .where.not(referrer:  nil)
      .where("started_at > ?", 1.months.ago)
      .group(:referrer)
      .order("count_all desc")
      .limit(10)
      .count
  end
end
