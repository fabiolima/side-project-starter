# frozen_string_literal: true

class Checkout::SessionCreator < ApplicationService
  include Rails.application.routes.url_helpers

  def initialize(user, price_id)
    @user = user
    @price_id = price_id
    super()
  end

  def create # rubocop:disable Metrics/MethodLength
    Stripe::Checkout::Session.create(
      customer: @user.stripe_id,
      client_reference_id: @user.id,
      success_url: "#{root_url + purchase_checkout_success_path}?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: pricing_url,
      payment_method_types: ["card"],
      mode: "subscription",
      # subscription_data: {
      #   trial_end: (Time.now + 3.days).to_i
      # },
      line_items: [{
        quantity: 1,
        price: @price_id
      }]
    )
  end
end
