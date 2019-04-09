# frozen_string_literal: true

class Address < ApplicationRecord
  self.inheritance_column = nil

  # virtual attributes
  attr_accessor :country

  # callbacks
  before_save :capitalize_attributes

  # enums
  enum type: { formal: 1, informal: 2 }

  # relations
  belongs_to :district
  belongs_to :user

  # validations
  validates :full_address, presence: true, length: { maximum: 255 }
  validates :phone_number, length: { maximum: 255 },
                           allow_blank: true,
                           telephone_number: { country: proc { |record| record.country }, types: [:mobile] }
  validates :type, uniqueness: { scope: :user }, inclusion: { in: types.keys }
  validates_with AddressAndIdentityValidator, on: :create

  private

  def capitalize_attributes
    self.full_address = full_address.capitalize_turkish
  end
end
