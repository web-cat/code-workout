# == Schema Information
#
# Table name: workouts
#
#  id                :integer          not null, primary key
#  name              :string(255)      default(""), not null
#  scrambled         :boolean          default(FALSE)
#  created_at        :datetime
#  updated_at        :datetime
#  description       :text
#  points_multiplier :integer
#  creator_id        :integer
#  external_id       :string(255)
#  is_public         :boolean
#
# Indexes
#
#  index_workouts_on_external_id  (external_id) UNIQUE
#  index_workouts_on_is_public    (is_public)
#

# =============================================================================
# Represents a collection of exercises given as an assignment.  A workout
# can be associated with one or more courses through workout offerings,
# which represent individual assignments of the same workout in different
# courses or terms.
#
# In addition, each user who starts a workout is associated with the
# workout through one or more WorkoutScores--these WorkoutScore objects
# represent that user's score on the exercises in one completion of this
# workout.
#
# Note that workouts can implicitly be "owned" by courses.  Effectively,
# the "courses" associated with a workout are those for which course
# offerings have been given workout offerings.
#
class Workout < ActiveRecord::Base

  #~ Relationships ............................................................

  acts_as_taggable_on :tags, :languages, :styles
	has_many :exercise_workouts, -> { order("'position' ASC") },
	  inverse_of: :workout, dependent: :destroy
  has_many :exercises, through:  :exercise_workouts
	has_many :workout_scores, inverse_of: :workout, dependent: :destroy
  has_many :users, through: :workout_scores
  has_many :attempts
  has_many :workout_offerings, inverse_of: :workout, dependent: :destroy
  has_many :course_offerings, through:  :workout_offerings
  has_many :courses, through: :course_offerings
  belongs_to :creator, class_name: 'User'
  has_many :workout_owners, inverse_of: :workout, dependent: :destroy
  has_many :owners, through: :workout_owners

  accepts_nested_attributes_for :exercise_workouts
  accepts_nested_attributes_for :workout_offerings


  #~ Validation ...............................................................

	validates :name,
    presence: true,
    length: { minimum: 1 },
    format: {
      with: /[a-zA-Z0-9\-_: .]+/,
      message: 'The workout name must consist only of letters, digits, ' \
        'hyphens (-), underscores (_), spaces ( ), colons (:) ' \
        ' and periods (.).'
    }


  #~ Hooks ....................................................................

  # paginates_per 1


  #~ Class methods ............................................................

  # -------------------------------------------------------------
  # FIXME: probably shouldn't be here, since it omits setting the
  # point value.
  def add_exercise(ex)
    self.exercise_workouts <<
      ExerciseWorkout.new(workout: self, exercise: ex)
  end


  # -------------------------------------------------------------
  # return the totals points of the exercises in the current workout.
  # FIXME: Why isn't this a property of the workout?  The exercises
  # themselves don't record absolute points at all!
  def total_points
    self.exercise_workouts.pluck(:points).reduce(0.0, :+)
  end


  # -------------------------------------------------------------
  # Simple method to return the number of exercises a workout has
  def num_exercises
    self.exercises.length
  end


  # -------------------------------------------------------------
  def contains?(exercise)
    self.exercise_workouts.where(exercise: exercise).any?
  end


  # -------------------------------------------------------------
  # returns a hash of exercise experience points (XP) with
  # { scored: ___, total: ___, percent: ___ }
  # FIXME: refactor to use workout score instead
  def xp(u_id)
    xp = Hash.new
    xp[:scored] = 0
    xp[:total] = 0
    exs = self.exercises
    exs.each do |x|
      x_attempt = x.attempts.where(user_id: u_id).pluck(:experience_earned)
      x_attempt.each do |a|
        xp[:scored] = xp[:scored] + a
      end
      xp[:total] = xp[:total] + x.experience
    end
    if  xp[:total] > 0
      xp[:percent] = xp[:scored].to_f / xp[:total].to_f * 100
    else
      xp[:percent] = 0
    end
    return xp
  end


  # ------------------------------------------------------------
  def next_exercise(ex, user, workout_score)
    if user.nil?
      puts "Invalid USER"
    end

    if workout_score.nil?
      workout_score = score_for(user)
    end

    position = 0
    if ex
      exw = exercise_workouts.where(exercise: ex).first
      if exw
        position = exw.position
      end
    end
    candidate = nil
    exercise_workouts.each do |x|
      if candidate.nil? ||
        (candidate.position <= position && x.position > position)
        attempt = Attempt.user_attempt(
          user, x.exercise.current_version, workout_score)
        if attempt.nil? || attempt.score < x.points
          candidate = x
        end
      end
    end
    if candidate.nil? && exercise_workouts.size > 0
      candidate = exercise_workouts.first
    end
    return candidate.exercise
  end


  # -------------------------------------------------------------
  def all_tags
    coll = self.tags.pluck(:tag_name).uniq
    self.exercises.each do |x|
      x_tags = x.tags.pluck(:tag_name).uniq
      x_tags.each do |another|
        if coll.index(another).nil?
          coll.push(another)
        end
      end
    end
    return coll
  end


  # -------------------------------------------------------------
  def highest_difficulty
    diff = 0
    self.exercises.each do |x|
      x_diff = x.andand.irt_data.andand.difficulty || 0
      if x_diff > diff
        diff = x_diff
      end
    end
    return diff
  end


  # -------------------------------------------------------------
  # FIXME: refactor to use workout score instead
  def xp_distribution(u_id)
    results = self.xp(u_id)
    earned = results[:scored]
    earned_per = results[:percent]
    total = results[:total]
    remaining = 0
    self.exercises.each do |x|
      x_attempt = x.attempts.where(user_id: u_id).pluck(:experience_earned)
      x_earned = 0
      x_attempt.each do |a|
        x_earned += a
      end
      remaining += x.experience - x_earned
    end
    remaining_per = remaining / total.to_f * 100
    gap = total - earned - remaining
    gap_per = 100 - earned_per - remaining_per
    return [earned, remaining, gap, earned_per, remaining_per, gap_per]
  end


  # -------------------------------------------------------------
  def score_for(user, workout_offering = nil)
    workout_scores.where(user: user, workout_offering: workout_offering).
      order('updated_at DESC').first
  end


  #~ Class methods ............................................................

  # -------------------------------------------------------------
  def self.search(terms)
    # FIXME: need to add visibility controls here
    return Workout.tagged_with(terms, wild: true, on: :tags) +
      Workout.tagged_with(terms, wild: true, on: :languages) +
      Workout.tagged_with(terms, wild: true, on: :styles)
  end

end
