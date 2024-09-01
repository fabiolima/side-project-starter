class Profile < ApplicationRecord
  belongs_to :user

  validates :first_name, presence: true, on: :update
  validates :last_name, presence: true, on: :update
end
