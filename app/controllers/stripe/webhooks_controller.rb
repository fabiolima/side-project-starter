class Stripe::WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :create ]

  def create
    # Replace this endpoint secret with your endpoint's unique secret
    # If you are testing with the CLI, find the secret by running 'stripe listen'
    # If you are using an endpoint defined with the API or dashboard, look in your webhook settings
    # at https://dashboard.stripe.com/webhooks
    webhook_secret = Rails.application.credentials.dig(:stripe, :webhook_secret)
    payload = request.body.read
    if !webhook_secret.empty?
      # Retrieve the event by verifying the signature using the raw body and secret if webhook signing is configured.
      sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
      event = nil

      begin
        event = Stripe::Webhook.construct_event(payload, sig_header, webhook_secret)
      rescue JSON::ParserError => e
        # Invalid payload
        status 400
        return
      rescue Stripe::SignatureVerificationError => e
        # Invalid signature
        puts "⚠️  Webhook signature verification failed."
        status 400
        return
      end
    else
      data = JSON.parse(payload, symbolize_names: true)
      event = Stripe::Event.construct_from(data)
    end

    # event_type = event["type"]
    # data = event["data"]
    # data_object = data["object"]
    #

    case event.type
    when "customer.created"; handle_customer_created(event)
    when "checkout.session.completed"; handle_checkout_completed(event)
    when "invoice.payment_succeeded"; handle_payment_succeeded(event)
    end

    render json: { message: "success" }
  end

  private

  def handle_customer_created(event)
    customer = event.data.object
    user = User.find_by(email: customer.email)
    user.update(stripe_id: customer.id) unless user.nil?
  end

  def handle_checkout_completed(event)
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
      user: user,
    )
  end

  def handle_payment_succeeded(event)
    invoice = event.data.object
    subscription_id = invoice.subscription
    payment_intent_id = invoice.payment_intent

    if invoice.billing_reason = "subscription_create"
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
      status: stripe_subscription.status,
    )
  end
end
