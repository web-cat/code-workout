# == Schema Information
#
# Table name: workout_offerings
#
#  id                       :bigint           not null, primary key
#  attempt_limit            :integer
#  hard_deadline            :datetime
#  lms_assignment_url       :string(255)
#  most_recent              :boolean          default(TRUE)
#  opening_date             :datetime
#  published                :boolean          default(TRUE), not null
#  soft_deadline            :datetime
#  time_limit               :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  continue_from_workout_id :bigint
#  course_offering_id       :bigint           not null
#  lms_assignment_id        :string(255)
#  lms_instance_id          :bigint
#  lti_assignment_id        :string(255)
#  workout_id               :bigint           not null
#  workout_policy_id        :bigint
#
# Indexes
#
#  idx_workout_offerings_on_lms_and_lti_assignment  (lms_instance_id,lti_assignment_id) UNIQUE
#  index_workout_offerings_on_course_offering_id    (course_offering_id)
#  index_workout_offerings_on_lms_assignment_id     (lms_assignment_id)
#  index_workout_offerings_on_lms_instance_id       (lms_instance_id)
#  index_workout_offerings_on_lti_assignment_id     (lti_assignment_id)
#  index_workout_offerings_on_workout_id            (workout_id)
#  index_workout_offerings_on_workout_policy_id     (workout_policy_id)
#  workout_offerings_continue_from_workout_id_fk    (continue_from_workout_id)
#
# Foreign Keys
#
#  fk_rails_...                                   (continue_from_workout_id => workout_offerings.id)
#  fk_rails_...                                   (course_offering_id => course_offerings.id)
#  fk_rails_...                                   (lms_instance_id => lms_instances.id)
#  fk_rails_...                                   (workout_id => workouts.id)
#  workout_offerings_continue_from_workout_id_fk  (continue_from_workout_id => workout_offerings.id)
#  workout_offerings_course_offering_id_fk        (course_offering_id => course_offerings.id)
#  workout_offerings_workout_id_fk                (workout_id => workouts.id)
#  workout_offerings_workout_policy_id_fk         (workout_policy_id => workout_policies.id)
#

# =============================================================================
# Represents a many-to-many relationship between workouts and course
# offerings, where each instance of the relationship represents one
# "assignment" for one "section" of a course.  Workout offerings have
# due dates that control when the students in the corresponding course
# offering can take the workout (and thus, when they must complete it).
#
class WorkoutOffering < ApplicationRecord

  #~ Relationships ............................................................

  belongs_to :workout, inverse_of: :workout_offerings
  belongs_to :workout_policy, inverse_of: :workout_offerings
  belongs_to :continue_from_workout, foreign_key: 'continue_from_workout_id',
    class_name: 'WorkoutOffering'
  belongs_to :course_offering, inverse_of: :workout_offerings
  belongs_to :lms_instance
  has_many :workout_scores, inverse_of: :workout_offering, dependent: :nullify
  has_many :student_extensions
  has_many :users, through: :student_extensions
  has_many :lti_workouts

  scope :visible_to_students, -> {
    left_outer_joins(:workout_policy).where(published: true)
    .where('workout_policy_id IS NULL OR workout_policies.invisible_before_review = ?', false)
    .where('opening_date IS NULL OR opening_date <= ?', Time.zone.now)
  }

  before_validation :ensure_workout_policy


  #~ Validation ...............................................................

  validates :course_offering, presence: true
  validates :workout, presence: true


  #~ Instance methods .........................................................

  # -----------------------------------------------------------------
  def score_for(user)
    if user.nil?
      return nil
    else
      if workout_scores.loaded?
        workout_scores.find { |ws| ws.user_id == user.id && ws.workout_id == workout_id }
      else
        # Explicitly include workout id in search for faster search using
        # the compound index
        workout_scores.where(user: user, workout: workout).
          order('updated_at DESC').first
      end
    end
  end


  # -----------------------------------------------------------------
  def extension_for(user)
    return nil unless user
    if student_extensions.is_a?(Array) || (student_extensions.respond_to?(:loaded?) && student_extensions.loaded?)
      student_extensions.find { |e| e.user_id == user.id }
    else
      student_extensions.find_by(user_id: user.id)
    end
  end


  # -----------------------------------------------------------------
  def time_limit_for(user)
    user_extension = extension_for(user)
    user_extension.andand.time_limit || self.time_limit
  end


  # -----------------------------------------------------------------
  def hard_deadline_for(user)
    user_ext = extension_for(user)
    # (1) student extension hard deadline
    return user_ext.hard_deadline if user_ext.andand.hard_deadline
    
    # (2) later of (offering hard deadline OR student extension soft deadline)
    deadline2 = [self.hard_deadline, user_ext.andand.soft_deadline].compact.max
    return deadline2 if deadline2
    
    # (3) offering soft deadline
    self.soft_deadline
  end


  # -----------------------------------------------------------------
  def opening_date_for(user)
    user_extension = extension_for(user)
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
    deadline = soft_deadline || hard_deadline

    if hard_deadline && hard_deadline.to_i < current_time
      return 1
    end

    if deadline.nil?
      return nil
    end

    if deadline.to_i - current_time > 86400
      return 4
    end
    return (deadline.to_i - current_time) / 3600

  end

  # -------------------------------------------------------------
  # Indicates whether an user can access a workout in an offering
  def can_be_seen_by?(user)
    now = Time.zone.now
    uscore = score_for(user)
    opens = opening_date_for(user)
    hard_deadline = hard_deadline_for(user)
    course_offering.is_staff?(user) ||
      (((opens == nil) || (opens <= now)) &&
      course_offering.is_enrolled?(user) &&
      published &&
      (uscore == nil ||
      !uscore.closed? ||
      !workout_policy.andand.no_review_before_close ||
        (hard_deadline && now >= hard_deadline)))
  end

  # ------------------------------------------------------------------
  # A method to determine the latest deadline for a workout,
  # i.e. the date beyond which the workout is closed for all students
  # in the course. If there are no student extensions for a workout,
  # return the hard deadline. Else return the maximum deadline
  # extension granted to a student enrolled in the course.

  def ultimate_deadline
    deadline = hard_deadline || soft_deadline
    [ deadline,
      student_extensions.maximum(:hard_deadline),
      student_extensions.maximum(:soft_deadline)
    ].compact.max
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
    return false unless course_offering.is_enrolled?(user)

    workout_score = workout_scores.loaded? ? workout_scores.select { |s| s.user_id == user.andand.id }.sort_by { |s| s.updated_at || Time.at(0) }.last : workout_scores.where(user: user).last
    return false if workout_score && workout_score.closed?
 
    now = Time.zone.now
    opens = opening_date_for(user)
    deadline = hard_deadline_for(user)

    course_offering.is_staff?(user) ||
      (((opens == nil) || (opens <= now)) &&
       ((deadline == nil) || (now <= deadline)))
  end


  # ----------------------------------------------------------------
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
          att = workout_score.attempts.where(exercise_version: ex).max_by(&:started_at)
        else
          att = workout_score.attempts.where(exercise_version: ex).max_by(&:score)
        end

        workout_score.scored_attempts << att
      end

      workout_score.recalculate_score!
    end
  end


  # ----------------------------------------------------------------
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
    @exercise_collection.add(@exercises.to_a.flatten)
  end


  #~ Private instance methods .................................................
  private

  def ensure_workout_policy
    if self.workout && self.workout_policy.nil?
      self.workout_policy = self.workout.workout_policy || WorkoutPolicy.create!
    end
  end
end
