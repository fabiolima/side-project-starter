# frozen_string_literal: true

# Handles admin home page.
class Admin::Dashboard::ProductsController < ApplicationController
  layout "administrator"
  before_action :authenticate_admin!

  def index
    @products = Product.all
  end

  def sync
    Product::StripeImporter.new.import

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(:products, partial: "products", locals: { products: Product.all })
      end

      format.html do
        redirect_to admin_dashboard_products_path, notice: "Products successfully imported."
      end
    end
  end
end
