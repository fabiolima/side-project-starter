# frozen_string_literal: true

# Handles Stripe webhooks
class Stripe::WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :create ]

  def create # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity
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
    when "customer.subscription.updated" then handle_subscription_updated(event)
    when "customer.subscription.deleted" then handle_subscription_deleted(event)
    when "checkout.session.completed" then handle_checkout_completed(event)
    when "invoice.payment_succeeded" then handle_payment_succeeded(event)
    when "invoice.payment_failed" then handle_payment_failed(event)
    when "product.updated" then handle_product_updated(event)
    end

    render json: { message: "success" }
  end

  private

  def handle_customer_created(event)
    customer = event.data.object
    user = User.find_by(email: customer.email)
    user&.update(stripe_id: customer.id)
  end

  def handle_checkout_completed(event)
    checkout_session = event.data.object

    Subscription::SubscriptionCreator.new(
      checkout_session.customer,
      checkout_session.subscription
    ).create

    user = User.find_by(stripe_id: checkout_session.customer)

    SubscriptionMailer.with(user:).subscription_created.deliver_now
  end

  def handle_payment_succeeded(event)
    invoice = event.data.object

    subscription = Subscription.find_by(stripe_subscription_id: invoice.subscription)

    return if subscription.nil?

    stripe_subscription = Stripe::Subscription.retrieve(invoice.subscription)

    subscription.update_with_stripe_subscription stripe_subscription
  end

  def handle_payment_failed(event)
    invoice = event.data.object
    user = User.find_by(stripe_id: invoice.customer)

    # User is at checkout page and he can try again.
    return if user.nil? || invoice.billing_reason == "subscription_create"

    subscription = Subscription.find_by(stripe_subscription_id: invoice.subscription)
    stripe_subscription = Stripe::Subscription.retrieve(invoice.subscription)

    subscription.update_with_stripe_subscription stripe_subscription

    SubscriptionMailer.with(user:).payment_failed.deliver_now
  end

  def handle_subscription_updated(event)
    stripe_subscription = event.data.object
    subscription = Subscription.find_by(stripe_subscription_id: stripe_subscription.id)

    # Maybe, because of concurrency, subscription still not created locally.
    # Let other callbacks handle the creation first.
    return if subscription.nil?

    subscription.update_with_stripe_subscription stripe_subscription
  end

  def handle_subscription_deleted(event)
    stripe_subscription = event.data.object
    puts stripe_subscription.status
    puts stripe_subscription.cancel_at
  end

  def handle_product_updated(event)
    stripe_product = event.data.object

    Product
      .where(stripe_product_id: stripe_product.id)
      .update({
                name: stripe_product.name,
                livemode: stripe_product.livemode,
                active: stripe_product.active
              })
  end

  def find_product(stripe_product_id)
    local_product = Product.find_by(stripe_product_id:)

    return local_product unless local_product.nil?

    stripe_product = Stripe::Product.retrieve(stripe_product_id)

    Product.create(
      stripe_product_id:,
      name: stripe_product.name
    )
  end
end
