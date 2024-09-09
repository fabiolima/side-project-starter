# frozen_string_literal: true

class Product < ApplicationRecord
  has_many :subscriptions, dependent: :destroy
end
