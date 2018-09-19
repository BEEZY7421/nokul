# frozen_string_literal: true

require 'test_helper'

class AcademicCalendarTest < ActiveSupport::TestCase
  # relations
  %i[
    calendar_events
    academic_term
    calendar_type
    unit_calendar_events
  ].each do |property|
    test "an academic calendar can communicate with #{property}" do
      assert academic_calendars(:lisans_calendar_fall_2017_2018).send(property)
    end
  end

  # validations: presence
  %i[
    name
    senate_decision_date
    senate_decision_no
  ].each do |property|
    test "presence validations for #{property} of an academic calendar" do
      academic_calendars(:lisans_calendar_fall_2017_2018).send("#{property}=", nil)
      assert_not academic_calendars(:lisans_calendar_fall_2017_2018).valid?
    end
  end

  # validations: uniqueness
  test 'academic_term should be unique based on calendar_type' do
    fake_calendar = academic_calendars(:lisans_calendar_fall_2017_2018).dup
    assert_not fake_calendar.valid?
    assert_not_empty fake_calendar.errors[:academic_term]
  end

  # delegations
  test 'name delegation responds to calendar_type name' do
    assert academic_calendars(:lisans_calendar_fall_2017_2018).type_name
  end
end