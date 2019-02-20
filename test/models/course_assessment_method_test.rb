# frozen_string_literal: true

require 'test_helper'

class CourseAssessmentMethodTest < ActiveSupport::TestCase
  extend Support::Minitest::AssociationHelper
  extend Support::Minitest::ValidationHelper

  # relations
  belongs_to :assessment_method
  belongs_to :course_evaluation_type

  # validations: presence
  validates_presence_of :percentage

  # validations: uniqueness
  validates_uniqueness_of :assessment_method

  # validations: numericality
  validates_numericality_of :percentage
  validates_numerical_range :percentage, greater_than_or_equal_to: 0
  validates_numerical_range :percentage, less_than_or_equal_to: 100
end
