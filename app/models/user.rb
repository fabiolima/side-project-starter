# frozen_string_literal: true

# User Model
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :lockable

  has_one :profile, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  after_create :init_profile, :create_stripe_customer

  def init_profile
    create_profile!
  end

  def create_stripe_customer
    Stripe::Customer.create(email:)
  end

  def active_subscription?
    subscriptions.any? { |sub| sub.status == "active" }
  end

  def active_subscription
    subscriptions.find { |sub| sub.status == "active" }
  end
end
