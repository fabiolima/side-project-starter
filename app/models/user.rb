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
    self.create_profile!
  end

  def create_stripe_customer
    Stripe::Customer.create(email: email)
  end
end
