# frozen_string_literal: true

class CreateSubscriptions < ActiveRecord::Migration[7.2]
  def change
    create_table :subscriptions do |t|
      t.string :stripe_subscription_id

      t.references :user, null: false, foreign_key: true
      t.references :price, null: false, foreign_key: true

      t.integer  :status, default: 3
      t.datetime :start_date
      t.datetime :ended_at
      t.datetime :current_period_end
      t.datetime :current_period_start
      t.datetime :cancel_at
      t.datetime :canceled_at

      t.timestamps
    end
  end
end
