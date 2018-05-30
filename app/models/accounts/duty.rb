# frozen_string_literal: true

class Duty < ApplicationRecord
  # relations
  belongs_to :employee
  belongs_to :unit
  has_many :positions, dependent: :destroy
  has_many :administrative_functions, through: :positions

  # validations
  validates :temporary, inclusion: { in: [true, false] }
  validates :start_date, presence: true
  validates :unit_id, uniqueness: { scope: %i[employee start_date] }
  validates_with DutyValidator

  # scopes
  scope :temporary, -> { where(temporary: true) }
  scope :tenure, -> { where(temporary: false) }
  scope :active, -> { where('end_date > ? OR end_date IS NULL', Time.zone.today) }

  # custom methods
  def active?
    end_date.nil? || end_date.future?
  end
end
