# frozen_string_literal: true

class CreatePrices < ActiveRecord::Migration[7.2]
  def change
    create_table :prices do |t|
      t.string :stripe_price_id
      t.string :currency
      t.string :interval
      t.boolean :active
      t.string :unit_amount_decimal
      t.integer :unit_amount
      t.references :product, null: false, foreign_key: true
      t.timestamps
    end

    add_index :prices, [:stripe_price_id], unique: true
  end
end
