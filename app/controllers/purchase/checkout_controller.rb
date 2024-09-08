# frozen_string_literal: true

# Handles checkout flow.
class Purchase::CheckoutController < ApplicationController
  before_action :authenticate_user!
  before_action :check_existing_subscription, only: [:create]

  def create # rubocop:disable Metrics/MethodLength
    price = create_params[:price_id] # passed in via the hidden field in pricing.html.erb

    session = Stripe::Checkout::Session.create(
      customer: current_user.stripe_id,
      client_reference_id: current_user.id,
      success_url: "#{root_url + purchase_checkout_success_path}?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: pricing_url,
      payment_method_types: ["card"],
      mode: "subscription",
      # subscription_data: {
      #   trial_end: (Time.now + 3.days).to_i
      # },
      line_items: [{
        quantity: 1,
        price:
      }]
    )

    redirect_to session.url, allow_other_host: true
  end

  def success
    session = Stripe::Checkout::Session.retrieve(params[:session_id])
    @customer = Stripe::Customer.retrieve(session.customer)
  end

  private

  def check_existing_subscription
    return unless current_user.current_subscription?

    redirect_to app_dashboard_billings_path, notice: "You already have subscription."
  end

  def create_params
    params.permit(:price_id, :authenticity_token)
  end
end
