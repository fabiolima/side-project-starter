# frozen_string_literal: true

class Customer::CustomerUpdater < ApplicationService
  def initialize(profile)
    @profile = profile
    super()
  end

  def update
    return unless customer? && need_update?

    Stripe::Customer.update(@profile.user.stripe_id, { name: @profile.full_name })
  end

  private

  def customer?
    @profile.user.stripe_id.present?
  end

  def need_update?
    @profile.saved_change_to_attribute?(:first_name) || @profile.saved_change_to_attribute?(:last_name)
  end
end
