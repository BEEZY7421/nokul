# frozen_string_literal: true

require 'test_helper'

class UnitCalendarEventTest < ActiveSupport::TestCase
  # relations
  %i[
    calendar_title
    unit
    academic_calendar
  ].each do |property|
    test "an unit calendar event can communicate with #{property}" do
      assert unit_calendar_events(:one).send(property)
    end
  end

  # validations: presence
  test 'should not save without start_date' do
    calendar_event = unit_calendar_events(:one)
    calendar_event.start_date = nil
    assert_not calendar_event.valid?
    assert_not_empty calendar_event.errors[:start_date]
  end

  # validations: uniqueness
  test 'unit event should be unique' do
    assert_not unit_calendar_events(:one).dup.valid?
  end
end