# frozen_string_literal: true

# Handles static pages
class StaticController < ApplicationController
  def pricing
    lookup_keys = Rails.application.credentials.dig(:stripe, :pricing).values
    @prices = Stripe::Price.list(lookup_keys:, active: true, expand: [ "data.product" ])
  end
end
