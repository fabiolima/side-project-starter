# frozen_string_literal: true

# Handles admin home page.
class Admin::Dashboard::ProductsController < ApplicationController
  layout "administrator"
  before_action :authenticate_admin!

  def index
    @products = Product.all
  end

  def sync # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    stripe_products = Stripe::Product.list

    stripe_products.each do |stripe_product|
      local_product = Product.find_by(stripe_product_id: stripe_product.id)

      if local_product.nil?
        create_product_from_stripe(stripe_product)
      else
        update_product_from_stripe(local_product,
                                   stripe_product)
      end
    end

    @products = Product.all

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(:products, partial: "products", locals: { products: @products })
      end

      format.html do
        redirect_to admin_dashboard_products_path, notice: "Products successfully imported."
      end
    end
  end

  private

  def create_product_from_stripe(stripe_product)
    Product.create({
                     name: stripe_product.name,
                     active: stripe_product.active,
                     livemode: stripe_product.livemode,
                     stripe_product_id: stripe_product.id

                   })
  end

  def update_product_from_stripe(local_product, stripe_product)
    local_product.update({
                           name: stripe_product.name,
                           active: stripe_product.active,
                           livemode: stripe_product.livemode
                         })
  end
end
