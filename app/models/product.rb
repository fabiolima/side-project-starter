# frozen_string_literal: true

class Product < ApplicationRecord
  has_many :subscriptions, dependent: :destroy
  has_many :prices, dependent: :destroy
end
