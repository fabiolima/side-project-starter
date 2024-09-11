# frozen_string_literal: true

# Subscription model that locally represents a Stripe::Subscription
class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :price

  def update_with_stripe_subscription(stripe_subscription) # rubocop:disable Metrics/AbcSize
    update(
      current_period_start: Time.at(stripe_subscription.current_period_start).to_datetime,
      current_period_end: Time.at(stripe_subscription.current_period_end).to_datetime,
      cancel_at: stripe_subscription.cancel_at ? Time.at(stripe_subscription.cancel_at).to_datetime : nil,
      canceled_at: stripe_subscription.canceled_at ? Time.at(stripe_subscription.canceled_at).to_datetime : nil,
      stripe_plan_id: stripe_subscription.plan.id,
      interval: stripe_subscription.plan.interval,
      status: stripe_subscription.status
    )
  end
end
