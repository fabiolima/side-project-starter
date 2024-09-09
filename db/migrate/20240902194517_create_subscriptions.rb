# frozen_string_literal: true

class CreateSubscriptions < ActiveRecord::Migration[7.2]
  def change
    create_table :subscriptions do |t|
      t.string :stripe_plan_id
      t.string :stripe_customer_id
      t.string :stripe_subscription_id
      t.string :stripe_price_id

      t.references :user, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true

      t.string :status
      t.string :interval
      t.string :price_unit_amount
      t.datetime :current_period_end
      t.datetime :current_period_start
      t.datetime :cancel_at
      t.datetime :canceled_at

      t.timestamps
    end
  end
end
