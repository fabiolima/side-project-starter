# frozen_string_literal: true

class Subscription::SubscriptionCreator < ApplicationService
  def initialize(stripe_customer_id, stripe_subscription_id)
    @stripe_customer_id = stripe_customer_id
    @stripe_subscription_id = stripe_subscription_id
    super()
  end

  def create # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    user = User.find_by(stripe_id: @stripe_customer_id)

    return if user.nil?

    stripe_subscription = Stripe::Subscription.retrieve(@stripe_subscription_id)
    item = stripe_subscription.items.data.first

    price = Price.find_by(stripe_price_id: item.price.id)

    return if price.nil?

    Subscription.create(
      user:,
      price:,
      stripe_subscription_id: stripe_subscription.id,
      status: stripe_subscription.status,
      current_period_start: Time.at(stripe_subscription.current_period_start).to_datetime,
      current_period_end: Time.at(stripe_subscription.current_period_end).to_datetime,
      cancel_at: stripe_subscription.cancel_at,
      canceled_at: stripe_subscription.canceled_at
    )
  end
end
