# frozen_string_literal: true

class CreateProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :products do |t|
      t.string :stripe_product_id
      t.string :name
      t.boolean :active
      t.boolean :livemode

      t.timestamps
    end

    add_index :products, [:stripe_product_id], unique: true
  end
end
