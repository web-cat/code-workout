# == Schema Information
#
# Table name: course_offerings
#
#  id                      :integer          not null, primary key
#  course_id               :integer          not null
#  term_id                 :integer          not null
#  label                   :string(255)      default(""), not null
#  url                     :string(255)
#  self_enrollment_allowed :boolean
#  created_at              :datetime
#  updated_at              :datetime
#  cutoff_date             :date
#  lms_instance_id         :integer
#
# Indexes
#
#  index_course_offerings_on_course_id        (course_id)
#  index_course_offerings_on_lms_instance_id  (lms_instance_id)
#  index_course_offerings_on_term_id          (term_id)
#

# =============================================================================
# Represents a single section (or offering) of a course in a specific term.
#
class CourseOffering < ActiveRecord::Base

  #~ Relationships ............................................................

  belongs_to :course, inverse_of: :course_offerings
  belongs_to :term, inverse_of: :course_offerings
  belongs_to :lms_instance, inverse_of: :course_offerings
  has_many :workout_offerings, inverse_of: :course_offering,
    dependent: :destroy
  has_many :workouts, through: :workout_offerings
  has_many :course_enrollments,
    # -> { includes(:course_role, :user).order(
    #   'course_roles.id ASC', 'users.last_name ASC', 'users.first_name ASC') },
    inverse_of: :course_offering,
    dependent: :destroy
  has_many :users, through: :course_enrollments
  has_many :exercise_collections

  accepts_nested_attributes_for :term

  scope :by_date,
    -> { includes(:term).order('terms.starts_on DESC', 'label ASC') }

  # FIXME: This scope seems to be broken. Use user.managed_course_offerings instead
  scope :managed_by_user, -> (u) { joins{course_enrollments}.
   where{ course_enrollments.user == u &&
    course_enrollments.course_role_id == CourseRole::INSTRUCTOR_ID } }
  scope :for_course_in_term, -> (c, t) { where { (course == c && term == t) } }


  #~ Validation ...............................................................

  validates :label, presence: true
  validates :course, presence: true
  validates :term, presence: true


  #~ Public instance methods ..................................................

  # -------------------------------------------------------------
  def display_name
    "#{course.number} (#{label})"
  end


  # -------------------------------------------------------------
  def name
    # FIXME: remove this method and use one of the other display_* methods
    self.course.name + ' - ' + self.term.display_name
  end


  # -------------------------------------------------------------
  def display_name_with_term
    "#{course.number} (#{term.display_name}, #{label})"
  end


  # -------------------------------------------------------------
  def display_name_with_org_and_term
    "#{course.organization.abbreviation} #{course.number} (#{term.display_name}, #{label})"
  end


  # -------------------------------------------------------------
  # Public: Gets a relation representing all Users who are allowed to
  # manage this CourseOffering.
  #
  def managers
    course_enrollments.where(course_roles: { can_manage_course: true }).
      map(&:user)
  end


  # -------------------------------------------------------------
  # Public: Gets a relation representing all Users who are students in
  # this CourseOffering.
  #
  def students
    course_enrollments.where(course_role: CourseRole.student).map(&:user)
  end


  # -------------------------------------------------------------
  # Public: Gets a relation representing all Users who are instructors in
  # this CourseOffering.
  #
  def instructors
    course_enrollments.where(course_role: CourseRole.instructor).map(&:user)
  end


  # -------------------------------------------------------------
  def effective_cutoff_date
    self.cutoff_date || self.term.ends_on
  end


  # -------------------------------------------------------------
  # Public: Returns a boolean indicating whether the offering is
  # currently available for self-enrollment
  def can_enroll?
    self.self_enrollment_allowed && effective_cutoff_date >= Time.now
  end


  # -------------------------------------------------------------
  # Public: Gets a relation representing all Users who are graders in
  # this CourseOffering.
  #
  def graders
    course_enrollments.where(course_role: CourseRole.grader).map(&:user)
  end


  # -------------------------------------------------------------
  def other_concurrent_offerings
    course.course_offerings.where(term: term, course: course)
  end


  # -------------------------------------------------------------
  def is_enrolled?(user)
    user && users.include?(user)
  end


  # -------------------------------------------------------------
  def is_manager?(user)
    role_for_user(user).andand.can_manage_course?
  end


  # -------------------------------------------------------------
  def is_instructor?(user)
    role_for_user(user).andand.is_instructor?
  end


  # -------------------------------------------------------------
  def is_grader?(user)
    role_for_user(user).andand.is_grader?
  end


  # -------------------------------------------------------------
  def is_staff?(user)
    role_for_user(user).andand.is_staff?
  end

  # -------------------------------------------------------------
  def is_student?(user)
    role_for_user(user).andand.is_student?
  end

  # -------------------------------------------------------------
  def role_for_user(user)
    user && course_enrollments.where(user: user).first.andand.course_role
  end

  def add_workout(workout, workout_offering_options={})
    found_workout = nil
    if workout.kind_of?(String)
      if workout_offering_options[:from_collection].to_b
        workouts = Workout.where('lower(name) = ?', workout)
        found_workout = workouts.andand.first
        new_workout = found_workout # using a workout from a collection (like OpenDSA), so use the one you find
      end
      if !found_workout
        instructor = self.instructors.first
        instructor_workout_offerings = instructor
          .managed_workout_offerings_in_term(workout.downcase, self.course, self.term).flatten
        found_workout = instructor_workout_offerings.first.andand.workout # same course and term, same workout
        new_workout = found_workout # we use this instead of a clone, since it's a sister course_offering

        if !found_workout
          # no other offering this semester is offering the workout, so look in past semesters
          instructor_workout_offerings = instructor
            .managed_workout_offerings_in_term(workout.downcase, self.course, nil).flatten
          found_workout = instructor_workout_offerings.andand
            .uniq{ |wo| wo.workout }.andand
            .sort_by{ |wo| wo.course_offering.term.starts_on }.andand
            .last.andand.workout
        end
      end

      if !found_workout
        return nil
      end
    end

    new_workout ||= found_workout.deep_clone!
    workout_offering = WorkoutOffering.new(
      workout: new_workout,
      course_offering: self,
      opening_date: workout_offering_options[:opening_date] || DateTime.now,
      soft_deadline: workout_offering_options[:soft_deadline],
      hard_deadline: workout_offering_options[:hard_deadline],
      lms_assignment_id: workout_offering_options[:lms_assignment_id]
    )
    workout_offering.save

    return workout_offering
  end
end
