# frozen_string_literal: true

class Subscription::SubscriptionUpdater < ApplicationService
  def initialize(stripe_subscription)
    @stripe_subscription = stripe_subscription
    super()
  end

  def update # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    subscription = Subscription.find_by(stripe_subscription_id: @stripe_subscription.id)

    return if subscription.nil?

    subscription.update(
      status: @stripe_subscription.status.to_sym,
      current_period_start: to_datetime(@stripe_subscription.current_period_start),
      current_period_end: to_datetime(@stripe_subscription.current_period_end),
      start_date: to_datetime(@stripe_subscription.start_date),
      ended_at: to_datetime(@stripe_subscription.ended_at),
      cancel_at: to_datetime(@stripe_subscription.cancel_at),
      canceled_at: to_datetime(@stripe_subscription.canceled_at)
    )
  end

  private

  def to_datetime(date)
    Time.at(date).to_datetime if date.present?
  end
end
