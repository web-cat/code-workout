# == Schema Information
#
# Table name: attempts
#
#  id                  :integer          not null, primary key
#  user_id             :integer          not null
#  exercise_version_id :integer          not null
#  submit_time         :datetime         not null
#  submit_num          :integer          not null
#  score               :float(24)        default(0.0)
#  experience_earned   :integer
#  created_at          :datetime
#  updated_at          :datetime
#  workout_score_id    :integer
#  active_score_id     :integer
#  feedback_ready      :boolean
#  time_taken          :decimal(10, )
#  feedback_timeout    :decimal(10, )
#  worker_time         :decimal(10, )
#
# Indexes
#
#  index_attempts_on_active_score_id      (active_score_id)
#  index_attempts_on_exercise_version_id  (exercise_version_id)
#  index_attempts_on_user_id              (user_id)
#  index_attempts_on_workout_score_id     (workout_score_id)
#

#table/schema migration for attempt........................
#    create_table :attempts do |t|
#      t.belongs_to :user, index: true, null: false
#      t.belongs_to :exercise, index: true, null: false
#      t.datetime :submit_time, null: false
#      t.integer :submit_num, null: false
#      t.text :answer
#      t.float :score
#      t.integer :experience_earned
#
#      t.timestamps
#    end


# =============================================================================
# The Attempt class represents one attempt at answering one Exercise.
# The Attempt is associated with the specific version of the exercise that
# was answered.  If the exercise was part of a workout, then the Attempt is
# also associated with the WorkoutScore for that workout through workout_score.
# If the Attempt is the most recent attempt--that is, if it is the attempt
# counted in the overall score for the workout, as opposed to some earlier
# but now superceded attempt--then it is /also/ related to the WorkoutScore
# through the active_score relation.  For past attempts that are /not/ being
# counted as part of the workout's score, the active_score relation should
# be kept at nil.
#
# In other words, all of the attempts for one exercise in one workout
# should have a valid workout_score relation pointing to the same WorkoutScore
# object, but only one of them (the most recent) should have a non-nil
# active_score relation ... and that non-nil active_score should be the
# same as its workout_score relation.
#
class Attempt < ActiveRecord::Base

  #~ Relationships ............................................................

  has_many :prompt_answers, inverse_of: :attempt, dependent: :destroy
  belongs_to :exercise_version, inverse_of: :attempts
  belongs_to :user, inverse_of: :attempts
  belongs_to :workout_score, inverse_of: :attempts
  belongs_to :active_score, class_name: 'WorkoutScore',
    foreign_key: 'active_score_id', inverse_of: :scored_attempts
  has_and_belongs_to_many :tag_user_scores


  #~ Validation ...............................................................

  validates :user, presence: true
  validates :exercise_version, presence: true
  validates :submit_time, presence: true
  validates :submit_num, numericality: { greater_than: 0 }
  validates :score, numericality: { greater_than_or_equal_to: 0 }


  #~ Class methods ............................................................

  # -------------------------------------------------------------
  # Returns the latest attempt of the given exercise by the given user
  def self.user_attempt(u, exv, workout_score)
    return Attempt.where(
      user: u, exercise_version: exv, workout_score: workout_score).
      where.not(score: nil).andand.last
  end


  #~ Instance methods .........................................................

  # -------------------------------------------------------------
  def update_score(score)
    old_score = self.score
    self.score = score
    if self.active_score
      # Multiply score by points from workout, if necessary
      self.score *= self.workout_score.workout.exercise_workouts.where(
        exercise: exercise_version.exercise).first.points
      self.workout_score.update_attempt(self, old_score)
    end
    self.save!
  end

  # -------------------------------------------------------------
  # Increase the score of an attempt by a specified amount
  # Doesn't have all the emotional baggage of update_score
  def rescore(delta)
    self.score += delta
    self.save!
  end

  # -------------------------------------------------------------
  def earned_full_points?
    if self.workout_score
      self.score >= self.workout_score.workout.exercise_workouts.where(
        exercise: exercise_version.exercise).first.points
    else
      self.score >= 1.0
    end
  end

end
