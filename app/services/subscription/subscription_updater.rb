# frozen_string_literal: true

class Subscription::SubscriptionUpdater < ApplicationService
  def initialize(stripe_subscription)
    @stripe_subscription = stripe_subscription
    super()
  end

  def update # rubocop:disable Metrics/AbcSize
    subscription = Subscription.find_by(stripe_subscription_id: @stripe_subscription.id)

    return if subscription.nil?

    subscription.update(
      current_period_start: Time.at(@stripe_subscription.current_period_start).to_datetime,
      current_period_end: Time.at(@stripe_subscription.current_period_end).to_datetime,
      cancel_at: @stripe_subscription.cancel_at ? Time.at(@stripe_subscription.cancel_at).to_datetime : nil,
      canceled_at: @stripe_subscription.canceled_at ? Time.at(@stripe_subscription.canceled_at).to_datetime : nil,
      status: @stripe_subscription.status
    )
  end
end
