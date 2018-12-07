class CreateCurriculumCourseGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :curriculum_course_groups do |t|
      t.references :course_group, foreign_key: true
      t.references :curriculum_semester, foreign_key: true
      t.decimal :ects, precision: 5, scale: 2, default: 0, null: false

      t.timestamps
    end
  end
end
