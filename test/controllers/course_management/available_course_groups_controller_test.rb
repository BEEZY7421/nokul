# frozen_string_literal: true

require 'test_helper'

module CourseManagement
  class AvailableCourseGroupsControllerTest < ActionDispatch::IntegrationTest
    setup do
      sign_in users(:serhat)
      @group = available_course_groups(:ati_group_1)
      @available_course = @group.available_course
    end

    test 'should get new' do
      get new_available_course_available_course_group_path(@available_course)
      assert_response :success
    end

    test 'should create available course group' do
      assert_difference('AvailableCourseGroup.count') do
        post available_course_available_course_groups_path(@available_course), params: {
          available_course_group: {
            name: 'Group 4', quota: 10,
            lecturers_attributes: {
              '0' => {
                lecturer_id: employees(:serhat_active).id,
                coordinator: true
              }
            }
          }
        }
      end

      group = AvailableCourseGroup.last

      assert_equal 'Group 4', group.name
      assert_equal 10, group.quota
      assert_redirected_to available_course_path(@available_course)
      assert_equal translate('.create.success'), flash[:info]
    end

    test 'should get edit' do
      get edit_available_course_available_course_group_path(@available_course, @group)
      assert_response :success
      assert_select '.card-header strong', translate('.edit.form_title')
    end

    test 'should update available course group' do
      group = AvailableCourseGroup.last
      patch available_course_available_course_group_path(group.available_course, group), params: {
        available_course_group: {
          name: 'Group 5', quota: 15,
          lecturers_attributes: {
            '0' => {
              lecturer_id: employees(:chief_john).id,
              coordinator: true
            }
          }
        }
      }

      group.reload

      assert_equal 'Group 5', group.name
      assert_equal 15, group.quota
      assert_redirected_to available_course_path(@available_course)
      assert_equal translate('.update.success'), flash[:info]
    end

    test 'should destroy available course group' do
      group = available_course_groups(:course_group_to_delete)

      assert_difference('AvailableCourseGroup.count', -1) do
        AvailableCourse.reset_counters(group.available_course.id, :groups_count)
        delete available_course_available_course_group_path(group.available_course, group)
      end

      assert_redirected_to available_course_path(@available_course)
      assert_equal translate('.destroy.success'), flash[:info]
    end

    private

    def translate(key)
      t("course_management.available_course_groups#{key}", course: @available_course.name)
    end
  end
end
