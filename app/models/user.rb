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

  after_create :init_profile

  def init_profile
    create_profile!
  end

  def current_subscription?
    Subscription.where(user: id, status: %w[active past_due trialing unpaid paused]).count.positive?
  end

  def current_subscription
    Subscription.where(user: id, status: %w[active past_due trialing unpaid paused]).first
  end
end
