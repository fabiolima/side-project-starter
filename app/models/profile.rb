# frozen_string_literal: true

# User's profile model.
class Profile < ApplicationRecord
  belongs_to :user

  validates :first_name, presence: true, on: :update
  validates :last_name, presence: true, on: :update

  def full_name
    "#{first_name} #{last_name}"
  end
end
