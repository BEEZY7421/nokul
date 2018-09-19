# frozen_string_literal: true

class CreateDistricts < ActiveRecord::Migration[5.2]
  def change
    create_table :districts do |t|
      t.string :name, unique: true, null: false
      t.string :mernis_code
      t.boolean :active, default: true, null: false
      t.references :city, foreign_key: true
    end
  end
end