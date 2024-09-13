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
      current_period_start: to_datetime(stripe_subscription.current_period_start),
      current_period_end: to_datetime(stripe_subscription.current_period_end),
      start_date: to_datetime(stripe_subscription.start_date),
      ended_at: to_datetime(stripe_subscription.ended_at),
      cancel_at: to_datetime(stripe_subscription.cancel_at),
      canceled_at: to_datetime(stripe_subscription.canceled_at)
    )
  end

  private

  def to_datetime(date)
    Time.at(date).to_datetime if date.present?
  end
end
