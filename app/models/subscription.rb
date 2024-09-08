# frozen_string_literal: true

# Subscription model that locally represents a Stripe::Subscription
class Subscription < ApplicationRecord
  belongs_to :user

  def update_with_stripe_subscription(stripe_subscription)
    update(
      current_period_start: Time.at(stripe_subscription.current_period_start).to_datetime,
      current_period_end: Time.at(stripe_subscription.current_period_end).to_datetime,
      stripe_plan_id: stripe_subscription.plan.id,
      interval: stripe_subscription.plan.interval,
      status: stripe_subscription.status
    )
  end
end
