# frozen_string_literal: true

require 'test_helper'

module Admin
  class DistrictsControllerTest < ActionDispatch::IntegrationTest
    setup do
      sign_in users(:john)
      @country = countries(:turkey)
      @city = cities(:samsun)
      @district = districts(:atakum)
    end

    test 'should get new' do
      get new_admin_country_city_district_path(@country, @city)
      assert_response :success
    end

    test 'should create district' do
      assert_difference('District.count') do
        post admin_country_city_districts_path(@country, @city),
             params: {
               district: {
                 name: 'Test District', mernis_code: '9999'
               }
             }
      end

      district = District.last

      assert_equal 'Test District', district.name
      assert_equal '9999', district.mernis_code
      assert_equal true, district.active
      assert_redirected_to admin_country_city_path(@country, @city)
      assert_equal translate('.create.success'), flash[:notice]
    end

    test 'should get edit' do
      get edit_admin_country_city_district_path(@country, @city, @district)
      assert_response :success
      assert_select '.simple_form' do
        assert_select '#district_name'
        assert_select '#district_mernis_code'
      end
    end

    test 'should update district' do
      district = District.first
      patch admin_country_city_district_path(@country, @city, District.first),
            params: {
              district: {
                name: 'Test District Update', mernis_code: '9998'
              }
            }

      district.reload

      assert_equal 'Test District Update', district.name
      assert_equal '9998', district.mernis_code
      assert_redirected_to admin_country_city_path(@country, @city)
      assert_equal translate('.update.success'), flash[:notice]
    end

    test 'should destroy district' do
      assert_difference('District.count', -1) do
        delete admin_country_city_district_path(@country, @city, District.first)
      end

      assert_redirected_to admin_country_city_path(@country, @city)
      assert_equal translate('.destroy.success'), flash[:notice]
    end

    private

    def translate(key)
      t("admin.districts#{key}")
    end
  end
end
