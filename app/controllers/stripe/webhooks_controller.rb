# frozen_string_literal: true

# Handles Stripe webhooks
class Stripe::WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :create ]

  def create # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    webhook_secret = Rails.application.credentials.dig(:stripe, :webhook_secret)
    payload = request.body.read

    if !webhook_secret.empty?
      # Retrieve the event by verifying the signature using the raw body and secret if webhook signing is configured.
      sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
      event = nil

      begin
        event = Stripe::Webhook.construct_event(payload, sig_header, webhook_secret)
      rescue JSON::ParserError
        # Invalid payload
        status 400
        return
      rescue Stripe::SignatureVerificationError
        # Invalid signature
        puts "⚠️  Webhook signature verification failed."
        status 400
        return
      end
    else
      data = JSON.parse(payload, symbolize_names: true)
      event = Stripe::Event.construct_from(data)
    end

    case event.type
    when "customer.created" then handle_customer_created(event)
    when "checkout.session.completed" then handle_checkout_completed(event)
    when "invoice.payment_succeeded" then handle_payment_succeeded(event)
    when "invoice.payment_failed" then handle_payment_failed(event)
    end

    render json: { message: "success" }
  end

  private

  def handle_customer_created(event)
    customer = event.data.object
    user = User.find_by(email: customer.email)
    user&.update(stripe_id: customer.id)
  end

  def handle_checkout_completed(event) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    customer = event.data.object
    return unless User.exists?(customer.client_reference_id)

    user = User.find(customer.client_reference_id)
    stripe_subscription = Stripe::Subscription.retrieve(customer.subscription)

    Subscription.create(
      stripe_subscription_id: stripe_subscription.id,
      stripe_customer_id: stripe_subscription.customer,
      stripe_plan_id: stripe_subscription.plan.id,
      status: stripe_subscription.status,
      current_period_start: Time.at(stripe_subscription.current_period_start).to_datetime,
      current_period_end: Time.at(stripe_subscription.current_period_end).to_datetime,
      interval: stripe_subscription.plan.interval,
      user:
    )
  end

  def handle_payment_succeeded(event) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    invoice = event.data.object
    subscription_id = invoice.subscription
    payment_intent_id = invoice.payment_intent

    if invoice.billing_reason == "subscription_create"
      # The subscription automatically activates after successful payment
      # Set the payment method used to pay the first invoice
      # as the default payment method for that subscription

      # Retrieve the payment intent used to pay the subscription
      payment_intent = Stripe::PaymentIntent.retrieve(payment_intent_id)

      # Set the default payment method
      Stripe::Subscription.update(subscription_id, default_payment_method: payment_intent.payment_method)
    end

    stripe_subscription = Stripe::Subscription.retrieve(subscription_id)
    subscription = Subscription.find_by(stripe_subscription_id: subscription_id)

    subscription.update(
      current_period_start: Time.at(stripe_subscription.current_period_start).to_datetime,
      current_period_end: Time.at(stripe_subscription.current_period_end).to_datetime,
      stripe_plan_id: stripe_subscription.plan.id,
      interval: stripe_subscription.plan.interval,
      status: stripe_subscription.status
    )
  end

  def handle_payment_failed(event)
    invoice = event.data.object
    # The payment failed or the customer does not have a valid payment method.
    # The subscription becomes past_due so we need to notify the customer and send them to the customer portal
    # to update their payment information.

    # Find the user by stripe id or customer id from Stripe event response
    user = User.find_by(stripe_id: invoice.customer)
    # Send an email to that customer detailing the problem with instructions on how to solve it.
    return unless user.nil?

    SubscriptionMailer.with(user:).payment_failed.deliver_now
  end
end
