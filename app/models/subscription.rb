# frozen_string_literal: true

# Subscription model that locally represents a Stripe::Subscription
class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :price
end
