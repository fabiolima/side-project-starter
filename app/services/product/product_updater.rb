# frozen_string_literal: true

class Product::ProductUpdater < ApplicationService
  def initialize(stripe_product)
    @stripe_product = stripe_product
    super()
  end

  def update
    Product
      .where(stripe_product_id: @stripe_product.id)
      .update({
                name: @stripe_product.name,
                livemode: @stripe_product.livemode,
                active: @stripe_product.active
              })
  end
end
