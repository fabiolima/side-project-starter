# frozen_string_literal: true

class Customer::CustomerCreator < ApplicationService
  def initialize(user)
    @user = user
    super()
  end

  def create
    customer = Stripe::Customer.create(email: @user.email, name: @user.profile.full_name)
    @user.update(stripe_id: customer.id)
  end
end
