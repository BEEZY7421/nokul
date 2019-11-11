# frozen_string_literal: true

class StudentDecorator < SimpleDelegator
  TOTAL_ECTS = 30

  def active_term
    @active_term ||= AcademicTerm.active.last
  end

  def registrable_for_online_course?
    calendar&.check_events('online_course_registrations')
  end

  def semester_enrollments
    @semester_enrollments ||=
      course_enrollments.where(semester: semester)
                        .includes(available_course: [curriculum_course: %i[course curriculum_semester]])
  end

  def enrollment_status
    @enrollment_status ||=
      if (statuses = semester_enrollments.pluck(:status)).any?
        statuses.include?('draft') ? :draft : :saved
      end
  end

  def selected_ects
    @selected_ects ||= semester_enrollments.sum(:ects).to_i
  end

  def selectable_ects
    @selectable_ects ||= TOTAL_ECTS + plus_ects - selected_ects
  end

  def selected_courses
    semester_enrollments.collect do |course_enrollment|
      [course_enrollment, can_drop?(course_enrollment.available_course)].flatten
    end
  end

  def selectable_courses
    course_catalog = []

    curriculum_semesters.each do |curriculum_semester|
      unless semester > curriculum_semester.sequence
        course_catalog << [curriculum_semester, selectable_courses_for(curriculum_semester)]
        return course_catalog unless !selectable_ects.negative? && enrolled_at?(curriculum_semester)
      end
    end
  end

  private

  def calendar
    calendars.last
  end

  def curriculum
    curriculums.active.last
  end

  def curriculum_semesters
    curriculum.semesters.where(term: active_term.term).order(:sequence)
  end

  def max_sequence
    @max_sequence ||= semester_enrollments.pluck(:sequence).max
  end

  def enrolled_at_group?(available_course)
    (semester_enrollments.pluck(:available_course_id) & available_course.group_courses.pluck(:id)).any?
  end

  def can_drop?(available_course)
    sequence = available_course.curriculum_course.curriculum_semester.sequence
    return [false, translate('must_drop_first')] if max_sequence > sequence

    true
  end

  def can_add?(available_course)
    if available_course.type == 'elective' && enrolled_at_group?(available_course)
      return [false, translate('.already_enrolled_at_group')]
    end

    return [false, translate('.not_enough_ects')] if selectable_ects < available_course.ects

    return [false, translate('.quota_full')] if available_course.quota_full?

    true
  end

  def selectable_courses_for(curriculum_semester)
    curriculum_semester.available_courses
                       .where(academic_term: active_term)
                       .where.not(id: semester_enrollments.pluck(:available_course_id))
                       .collect { |available_course| [available_course, can_add?(available_course)].flatten }
  end

  def enrolled_at?(curriculum_semester)
    enrolled_course_ids = semester_enrollments.pluck(:available_course_id)
    enrolled_at = true

    CurriculumSemesterDecorator.new(curriculum_semester).active_available_courses.collect(&:ids).each do |ids|
      break unless enrolled_at &&= (enrolled_course_ids & ids).any?
    end

    enrolled_at
  end

  def translate(key)
    I18n.t("studentship.course_enrollments.new.#{key}")
  end
end
