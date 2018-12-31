# frozen_string_literal: true

module Admin
  class UnitInstructionTypesController < ApplicationController
    include ReferenceResource

    private

    def secure_params
      params.require(:unit_instruction_type).permit(:name, :code)
    end
  end
end