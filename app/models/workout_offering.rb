# == Schema Information
#
# Table name: workout_offerings
#
#  id                       :integer          not null, primary key
#  course_offering_id       :integer          not null
#  workout_id               :integer          not null
#  created_at               :datetime
#  updated_at               :datetime
#  opening_date             :datetime
#  soft_deadline            :datetime
#  hard_deadline            :datetime
#  published                :boolean          default(TRUE), not null
#  time_limit               :integer
#  workout_policy_id        :integer
#  continue_from_workout_id :integer
#  lms_assignment_id        :string(255)
#  most_recent              :boolean          default(TRUE)
#  lms_assignment_url       :string(255)
#  attempt_limit            :integer
#
# Indexes
#
#  index_workout_offerings_on_course_offering_id  (course_offering_id)
#  index_workout_offerings_on_lms_assignment_id   (lms_assignment_id)
#  index_workout_offerings_on_workout_id          (workout_id)
#  index_workout_offerings_on_workout_policy_id   (workout_policy_id)
#  workout_offerings_continue_from_workout_id_fk  (continue_from_workout_id)
#

# =============================================================================
# Represents a many-to-many relationship between workouts and course
# offerings, where each instance of the relationship represents one
# "assignment" for one "section" of a course.  Workout offerings have
# due dates that control when the students in the corresponding course
# offering can take the workout (and thus, when they must complete it).
#
class WorkoutOffering < ActiveRecord::Base

  #~ Relationships ............................................................

  belongs_to :workout, inverse_of: :workout_offerings
  belongs_to :workout_policy, inverse_of: :workout_offerings
  belongs_to :continue_from_workout, foreign_key: 'continue_from_workout_id',
    class_name: 'WorkoutOffering'
  belongs_to :course_offering, inverse_of: :workout_offerings
  has_many :workout_scores, inverse_of: :workout_offering, dependent: :nullify
  has_many :student_extensions
  has_many :users, through: :student_extensions
  has_many :lti_workouts

  scope :visible_to_students, -> { joins{workout_policy.outer}.where{
    (published == true) &
    ((workout_policy_id == nil) | (workout_policy.invisible_before_review == false)) &
    ((opening_date == nil) | (opening_date <= Time.zone.now)) } }


  #~ Validation ...............................................................

  validates :course_offering, presence: true
  validates :workout, presence: true


  #~ Instance methods .........................................................

  # -----------------------------------------------------------------
  def score_for(user)
    if user.nil?
      return nil
    else
      workout_scores.where(user: user).order('updated_at DESC').first
    end
  end


  # -----------------------------------------------------------------
  def time_limit_for(user)
    user_extension =
      StudentExtension.find_by(user: user, workout_offering: self)
    user_extension.andand.time_limit || self.time_limit
  end


  # -----------------------------------------------------------------
  def hard_deadline_for(user)
    user_extension = student_extensions.where(user: user).first
    user_extension.andand.hard_deadline ||
      self.hard_deadline ||
      user_extension.andand.soft_deadline ||
      self.soft_deadline
  end


  # -----------------------------------------------------------------
  def opening_date_for(user)
    user_extension =
      StudentExtension.find_by(user: user, workout_offering: self)
    user_extension.andand.opening_date ||
      self.opening_date
  end


  # --------------------------------------------------------------------------------
  # Describes how 'far' is the workout offering from its hard and soft deadlines.
  # 4 indicates that there is more than one day remaining to soft deadline
  # 1 indicates that it is past the hard deadline
  # nil indicates that there is no valid deadline
  # Else it will return the number of hours remaining to the soft deadline
  def current_deadline_distance
    current_time = Time.zone.now.to_i

    if hard_deadline.nil?
      return nil
    end

    if soft_deadline.nil?
      return nil
    end

    if hard_deadline.to_i < current_time
      return 1
    end

    if soft_deadline.to_i - current_time > 86400
      return 4
    end
    return (soft_deadline.to_i - current_time)/ 3600

  end

  # -------------------------------------------------------------
  # Indicates whether an user can access a workout in an offering
  def can_be_seen_by?(user)
    now = Time.zone.now
    uscore = score_for(user)
    opens = opening_date_for(user)
    course_offering.is_staff?(user) ||
      (((opens == nil) || (opens <= now)) &&
      course_offering.is_enrolled?(user) &&
      published &&
      (uscore == nil ||
      !uscore.closed? ||
      !workout_policy.andand.no_review_before_close ||
      now >= hard_deadline_for(user)))
  end

  # ------------------------------------------------------------------
  # A method to determine the latest deadline for a workout,
  # i.e. the date beyond which the workout is closed for all students
  # in the course. If there are no student extensions for a workout,
  # return the hard deadline. Else return the maximum deadline
  # extension granted to a student enrolled in the course.

  def ultimate_deadline
    deadline = hard_deadline || soft_deadline
    if student_extensions.any?
      ext_deadline = student_extensions.maximum(:hard_deadline) ||
        student_extensions.maximum(:soft_deadline)
      if ext_deadline && (!deadline || ext_deadline > deadline)
        deadline = ext_deadline
      end
    end
    deadline
  end

  # -------------------------------------------------------------------
  # Method supplementary to the ultimate_deadline method
  # Returns a boolean indicating whether the workout is now shutdown
  # i.e. completely out of bounds for practice for all students

  def shutdown?
    now = Time.zone.now
    deadline = ultimate_deadline
    x = deadline && now > ultimate_deadline
    # FIXME: broken kludge
    x && !workout_policy.andand.no_review_before_close
#    puts "\n\n\n\nshutdown? = #{x}\n#{caller}\n\n\n\n"
    x
  end

  # -------------------------------------------------------------
  # Method that determines whether the given user can practice
  # this workout offering. The method looks up if the user has
  # any extension for this workout and if so 'normalizes' her
  # deadlines for this workout offering. Course staff always
  # have full access.

  def can_be_practiced_by?(user)
    workout_score = user.workout_scores.find_by(workout_offering: self)
    now = Time.zone.now
    user_extension = StudentExtension.find_by(user: user, workout_offering: self)
    deadline = user_extension.andand.hard_deadline ||
      self.hard_deadline ||
      user_extension.andand.soft_deadline ||
      self.soft_deadline
    opens = user_extension.andand.opening_date || self.opening_date
    course_offering.is_staff?(user) ||
    (((opens == nil) || (opens <= now)) &&
      ((deadline == nil) || (now <= deadline)) &&
      (!workout_score.andand.closed?) &&
      course_offering.is_enrolled?(user))
  end

  def show_feedback?
     workout_policy.andand.hide_feedback_before_finish ? false : true
  end

  # ----------------------------------------------------------------
  # Re-score all workout_scores for this offering based on its 'most_recent'
  # value.
  def rescore_all
    workout_scores.each do |workout_score|
      scored_for_this = workout_score.scored_attempts
      scored_for_this.each do |a|
        workout_score.scored_attempts.delete(a)
      end

      exercise_versions = workout_score.attempts.map(&:exercise_version)
      exercise_versions.each do |ex|
        if most_recent
          att = workout_score.attempts.where(exercise_version: ex).max_by(&:created_at)
        else
          att = workout_score.attempts.where(exercise_version: ex).max_by(&:score)
        end

        workout_score.scored_attempts << att
      end

      workout_score.recalculate_score!
    end
  end

  def organize_private_exercises
    @course = self.course_offering.course
    @user_group = @course.user_group
    if !@user_group
      @user_group = UserGroup.create(
        course: @course,
        name: @course.number,
        description: "Privileged user for #{@course.display_name}"
      )
    end

    @exercise_collection = @user_group.exercise_collection
    if !@exercise_collection
      @exercise_collection = ExerciseCollection.create(
        name: "#{@course.display_name} exercises",
        description: "Exercises commonly used in #{@course.number}",
        user_group: @user_group
      )
    end

    @exercises = self.workout.exercises.where(is_public: false)
    @exercise_collection.add(@exercises.flatten)
  end
end
