# frozen_string_literal: true

# User's profile model.
class Profile < ApplicationRecord
  belongs_to :user

  validates :first_name, presence: true, on: :update
  validates :last_name, presence: true, on: :update

  # after_update :update_stripe_customer

  # def update_stripe_customer
  #   return unless
  #     saved_change_to_attribute?(:first_name) ||
  #     saved_change_to_attribute?(:last_name) || user.stripe_id.nil?

  #   Stripe::Customer.update(user.stripe_id, { name: full_name })
  # end

  def full_name
    "#{first_name} #{last_name}"
  end
end
