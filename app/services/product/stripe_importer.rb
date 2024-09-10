# frozen_string_literal: true

class Product::StripeImporter < ApplicationService
  def import
    import_products
    import_prices
  end

  private

  def import_products
    stripe_products = Stripe::Product.list

    stripe_products.each do |stripe_product|
      local_product = Product.find_by(stripe_product_id: stripe_product.id)

      if local_product.nil?
        create_product_from_stripe stripe_product
      else
        update_product_from_stripe(local_product,
                                   stripe_product)
      end
    end
  end

  def import_prices
    stripe_prices = Stripe::Price.list

    stripe_prices.each do |stripe_price|
      local_price = Price.find_by(stripe_price_id: stripe_price.id)

      if local_price.nil?
        create_price_from_stripe stripe_price
      else
        update_price_from_stripe(local_price, stripe_price)
      end
    end
  end

  def update_price_from_stripe(local_price, stripe_price)
    clean_price_params = clean_price(stripe_price)
    local_price.update(clean_price_params)
  end

  def create_price_from_stripe(stripe_price)
    product = Product.find_by(stripe_product_id: stripe_price[:product])
    clean_price_params = clean_price stripe_price
    Price.create(clean_price_params.merge(product:))
  end

  def create_product_from_stripe(stripe_product)
    clean_product_params = clean_product stripe_product
    Product.create(clean_product_params)
  end

  def update_product_from_stripe(local_product, stripe_product)
    clean_product_params = clean_product stripe_product
    local_product.update(clean_product_params)
  end

  def clean_price(stripe_price)
    {
      active: stripe_price.active,
      interval: stripe_price.recurring.interval,
      currency: stripe_price.currency,
      unit_amount: stripe_price.unit_amount,
      stripe_price_id: stripe_price.id,
      unit_amount_decimal: stripe_price.unit_amount_decimal

    }
  end

  def clean_product(stripe_product)
    {
      name: stripe_product.name,
      active: stripe_product.active,
      livemode: stripe_product.livemode,
      stripe_product_id: stripe_product.id
    }
  end
end
