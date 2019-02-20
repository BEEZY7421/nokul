# frozen_string_literal: true

require 'test_helper'

class UniversityTypeTest < ActiveSupport::TestCase
  extend Support::Minitest::AssociationHelper
  include ReferenceTestModule

  # relations
  has_many :units, dependent: :nullify
end
