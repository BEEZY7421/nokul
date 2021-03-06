# frozen_string_literal: true

require 'test_helper'

class UnitsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:john)
    @unit = units(:omu)
  end

  test 'should get index' do
    get units_path
    assert_response :success
    assert_select '#add-button', t('units.index.new_unit_link')
  end

  test 'should get show' do
    get unit_path(@unit)
    assert_response :success
  end

  test 'should get new' do
    get new_unit_path
    assert_response :success
  end

  test 'should create unit' do
    assert_difference('Unit.count') do
      post units_path params: {
        unit: {
          name:                         'Test Unit',
          yoksis_id:                    200_000,
          founded_at:                   '1.1.2018',
          duration:                     1,
          unit_type_id:                 unit_types(:faculty).id,
          district_id:                  districts(:atakum).id,
          unit_status_id:               unit_statuses(:active).id,
          unit_instruction_language_id: unit_instruction_languages(:turkish).id,
          unit_instruction_type_id:     unit_instruction_types(:normal_education).id,
          parent_id:                    units(:omu).id
        }
      }
    end

    unit = Unit.last

    assert_equal 'Test Unit', unit.name
    assert_equal 200_000, unit.yoksis_id
    assert_equal 'Fakülte', unit.unit_type.try(:name)
    assert_equal units(:omu), unit.parent
    assert_redirected_to unit_path(unit)
    assert_equal t('units.create.success'), flash[:notice]
  end

  test 'should get edit' do
    get edit_unit_path(@unit)
    assert_response :success
    assert_select '.card-header strong', t('units.edit.form_title')
  end

  test 'should update unit' do
    unit = Unit.last
    patch unit_path(unit), params: {
      unit: {
        name:                         'Test Unit Update',
        yoksis_id:                    300_000,
        founded_at:                   '1.1.2018',
        duration:                     2,
        unit_type_id:                 unit_types(:research_center).id,
        district_id:                  districts(:atakum).id,
        unit_status_id:               unit_statuses(:active).id,
        unit_instruction_language_id: unit_instruction_languages(:turkish).id,
        unit_instruction_type_id:     unit_instruction_types(:normal_education).id,
        parent_id:                    units(:cbu).id
      }
    }

    unit.reload

    assert_equal 'Test Unit Update', unit.name
    assert_equal 300_000, unit.yoksis_id
    assert_equal 'Uygulama ve Araştırma Merkezi', unit.unit_type.try(:name)
    assert_equal units(:cbu), unit.parent
    assert_redirected_to unit_path(unit)
    assert_equal translate('units.update.success'), flash[:notice]
  end

  test 'should destroy unit' do
    @unit = units(:unit_to_delete)
    assert_difference('Unit.count', -@unit.subtree.count) do
      delete unit_path(@unit)
    end

    assert_redirected_to units_path
    assert_equal translate('units.destroy.success'), flash[:notice]
  end

  test 'should get programs' do
    get programs_unit_path(units(:egitim_bilimleri_enstitusu), format: :json)
    json_response = JSON.parse(response.body)
    assert_equal 1, json_response.length
    assert_equal units(:alman_dili_egitimi_dr).id, json_response[0]['id']
    assert_response :success
  end
end
