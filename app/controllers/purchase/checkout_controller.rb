# frozen_string_literal: true

# Handles checkout flow.
class Purchase::CheckoutController < ApplicationController
  before_action :authenticate_user!
  before_action :check_existing_subscription, only: [:create]

  def create
    price_id = create_params[:price_id]

    Customer::CustomerCreator.new(current_user).create unless current_user.stripe_id
    session = Checkout::SessionCreator.new(current_user, price_id).create

    redirect_to session.url, allow_other_host: true
  end

  def success
    # In case you need Stripe's session
    # session = Stripe::Checkout::Session.retrieve(params[:session_id])
    @user = current_user
  end

  private

  def check_existing_subscription
    return unless current_user.current_subscription?

    redirect_to app_dashboard_billings_path, notice: "You are already subscribed."
  end

  def create_params
    params.permit(:price_id, :authenticity_token)
  end
end
