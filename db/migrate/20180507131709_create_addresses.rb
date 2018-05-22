# frozen_string_literal: true

class CreateAddresses < ActiveRecord::Migration[5.1]
  def change
    create_table :addresses do |t|
      t.integer :name, null: false, default: 4
      t.string :phone_number, null: false, default: ''
      t.text :full_address, null: false
      t.references :district, foreign_key: true
      t.references :user, foreign_key: true
      t.timestamps
    end
  end
end
