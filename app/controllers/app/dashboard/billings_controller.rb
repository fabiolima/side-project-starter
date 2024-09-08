# frozen_string_literal: true

# Handles the home page of user's dashboard.
class App::Dashboard::BillingsController < ApplicationController
  before_action :authenticate_user!
  layout "user_administrator"
  def index; end

  # POST /app/dashboard/billings
  # Redirect to Stripe's customer portal.
  def billings
    session = Stripe::BillingPortal::Session.create({
                                                      customer: current_user.stripe_id,
                                                      return_url: app_dashboard_url
                                                    })

    redirect_to session.url, allow_other_host: true # hits stripe directly
  end

  def show
    return unless current_user.current_subscription?

    @subscription = current_user.current_subscription
  end
end
