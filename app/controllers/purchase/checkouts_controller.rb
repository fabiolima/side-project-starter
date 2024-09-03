class Purchase::CheckoutsController < ApplicationController
  before_action :authenticate_user!

  def create
    price = create_params[:price_id] # passed in via the hidden field in pricing.html.erb

    session = Stripe::Checkout::Session.create(
      customer: current_user.stripe_id,
      client_reference_id: current_user.id,
      success_url: root_url + "success?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: pricing_url,
      payment_method_types: [ "card" ],
      mode: "subscription",
      line_items: [ {
        quantity: 1,
        price: price
      } ]
    )

    # render json: { session_id: session.id } # if you want a json response
    redirect_to session.url, allow_other_host: true
  end

  private

  def create_params
    params.permit(:price_id)
  end
end
