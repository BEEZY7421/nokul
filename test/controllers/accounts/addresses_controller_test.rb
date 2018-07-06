# frozen_string_literal: true

require 'test_helper'

module Accounts
  class AddressesController < ActionDispatch::IntegrationTest
    setup do
      @user = users(:serhat)
      sign_in @user
    end

    test 'should get index' do
      get addresses_path
      assert_response :success

      assert_select '#add-button', translate('.index.new_address')
    end

    test 'should get new' do
      get new_address_path
      assert_response :success
    end

    test 'should create address' do
      assert_difference('@user.addresses.count') do
        post addresses_path, params: {
          address: {
            name: :work, phone_number: '03623121919', full_address: 'OMU BAUM', district_id: districts(:gerze).id
          }
        }
      end

      address = @user.addresses.find_by(name: :work)

      assert_equal '03623121919', address.phone_number
      assert_equal 'Omu Baum', address.full_address
      assert_equal districts(:gerze), address.district

      assert_redirected_to addresses_path
      assert_equal translate('.create.success'), flash[:notice]
    end

    test 'should not get edit for formal address' do
      formal_address = @user.addresses.find_by(name: :formal)

      get edit_address_path(formal_address)
      assert_response :redirect

      assert_equal translate('.edit.warning'), flash[:notice]
    end

    test 'should get edit for any address except formal' do
      address = @user.addresses.where.not(name: :formal).first

      get edit_address_path(address)
      assert_response :success
      assert_select '.card-header strong', translate('.edit.form_title')
    end

    test 'should update address' do
      address = @user.addresses.where.not(name: :formal).first

      patch address_path(address), params: {
        address: {
          phone_number: '03623121920', full_address: 'OMU UZEM'
        }
      }

      address.reload

      assert_equal '03623121920', address.phone_number
      assert_equal 'Omu Uzem', address.full_address

      assert_redirected_to addresses_path
      assert_equal translate('.update.success'), flash[:notice]
    end

    test 'should not destroy for formal address' do
      assert_difference('@user.addresses.count', 0) do
        delete address_path(@user.addresses.find_by(name: :formal))
      end

      assert_redirected_to addresses_path
      assert_equal translate('.destroy.warning'), flash[:notice]
    end

    test 'should destroy for any address except formal' do
      assert_difference('@user.addresses.count', -1) do
        delete address_path(@user.addresses.where.not(name: :formal).first)
      end

      assert_redirected_to addresses_path
      assert_equal translate('.destroy.success'), flash[:notice]
    end

    private

    def translate(key)
      t("account.addresses#{key}")
    end
  end
end
