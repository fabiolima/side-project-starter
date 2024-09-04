# frozen_string_literal: true

class CreateSubscriptions < ActiveRecord::Migration[7.2]
  def change
    create_table :subscriptions do |t|
      t.string :stripe_plan_id
      t.string :stripe_customer_id
      t.string :stripe_subscription_id
      t.references :user, null: false, foreign_key: true
      t.string :status
      t.string :interval
      t.datetime :current_period_end
      t.datetime :current_period_start

      t.timestamps
    end
  end
end
