class Profile < ApplicationRecord
  belongs_to :user

  validates :first_name, presence: true, on: :update
  validates :last_name, presence: true, on: :update

  after_update :update_stripe_customer

  def update_stripe_customer
    return unless
      saved_change_to_attribute?(:first_name) ||
      saved_change_to_attribute?(:last_name) || self.user.stripe_id.nil?

    Stripe::Customer.update(self.user.stripe_id, { name:  full_name })
  end

  def full_name
    "#{self.first_name} #{self.last_name}"
  end
end
