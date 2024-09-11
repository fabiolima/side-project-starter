# frozen_string_literal: true

class Stripe::WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :create ]
  before_action :set_event

  def create # rubocop:disable Metrics/CyclomaticComplexity
    case @event.type
    when "customer.created" then handle_customer_created(@event)
    when "customer.subscription.updated" then handle_subscription_updated(@event)
    when "customer.subscription.deleted" then handle_subscription_deleted(@event)
    when "checkout.session.completed" then handle_checkout_completed(@event)
    when "invoice.payment_succeeded" then handle_payment_succeeded(@event)
    when "invoice.payment_failed" then handle_payment_failed(@event)
    when "product.updated" then handle_product_updated(@event)
    end

    render json: { message: "success" }
  end

  private

  def set_event # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    webhook_secret = Rails.application.credentials.dig(:stripe, :webhook_secret)
    payload = request.body.read
    @event = nil

    if !webhook_secret.empty?
      # Retrieve the event by verifying the signature using the raw body and secret if webhook signing is configured.
      sig_header = request.env["HTTP_STRIPE_SIGNATURE"]

      begin
        @event = Stripe::Webhook.construct_event(payload, sig_header, webhook_secret)
      rescue JSON::ParserError
        status 400
        nil
      rescue Stripe::SignatureVerificationError
        puts "Webhook signature verification failed."
        status 400
        nil
      end
    else
      data = JSON.parse(payload, symbolize_names: true)
      @event = Stripe::Event.construct_from(data) # return event.
    end
  end

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
    stripe_subscription = Stripe::Subscription.retrieve(invoice.subscription)
    Subscription::SubscriptionUpdater.new(stripe_subscription).update
  end

  def handle_payment_failed(event)
    invoice = event.data.object
    return if invoice.billing_reason == "subscription_create"

    stripe_subscription = Stripe::Subscription.retrieve(invoice.subscription)
    Subscription::SubscriptionUpdater.new(stripe_subscription).update

    user = User.find_by(stripe_id: invoice.customer)
    return if user.nil?

    SubscriptionMailer.with(user:).payment_failed.deliver_now
  end

  def handle_subscription_updated(event)
    stripe_subscription = event.data.object
    Subscription::SubscriptionUpdater.new(stripe_subscription).update
  end

  def handle_subscription_deleted(event)
    stripe_subscription = event.data.object
    Subscription::SubscriptionUpdater.new(stripe_subscription).update
  end

  def handle_product_updated(event)
    stripe_product = event.data.object
    Product::ProductUpdater.new(stripe_product).update
  end
end
