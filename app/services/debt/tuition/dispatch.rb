# frozen_string_literal: true

require_relative 'process/daytime_education'
require_relative 'process/evening_education'

module Debt
  module Tuition
    module Dispatch
      module_function

      def perform(units, academic_term)
        units.each do |unit|
          unit.students.active.each do |student|
            chain   = set_chain(unit, student)
            tuition = unit.tuitions.find_by(academic_term_id: academic_term)
            next if tuition.nil?

            debt = TuitionDebt.new(student, tuition.unit_tuitions.first)
            chain.call(debt)
          end
        end
      end

      def set_chain(unit, student)
        if unit.evening?
          Process::EveningEducation.new(student).chain
        else
          Process::DaytimeEducation.new(student).chain
        end
      end
    end
  end
end