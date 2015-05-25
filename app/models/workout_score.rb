# == Schema Information
#
# Table name: workout_scores
#
#  id                  :integer          not null, primary key
#  workout_id          :integer          not null
#  user_id             :integer          not null
#  score               :float
#  completed           :boolean
#  completed_at        :datetime
#  last_attempted_at   :datetime
#  exercises_completed :integer
#  exercises_remaining :integer
#  created_at          :datetime
#  updated_at          :datetime
#  workout_offering_id :integer
#
# Indexes
#
#  index_workout_scores_on_user_id     (user_id)
#  index_workout_scores_on_workout_id  (workout_id)
#


# =============================================================================
# Represents all of the attempts on each exercise in a workout by one
# student.
#
# In the context of a course offering, a workout should have a workout
# offering that specifies the due date.  For each student in the course
# offering who has done any work in that workout, there will be one
# WorkoutScore object, related to the student (user) who provided the
# answers, the WorkoutOffering being completed, and the corresponding
# Workout (which should be the same as the one in the workout offering).
#
# This object then represents the corresponding user's score on the
# workout, and has associations with all of that user's attempts created
# as part of this workout on all of the exercises in the workout.
#
# The attempts relation points to every exercise attempt completed as
# part of taking the corresponding workout offering.  In addition, the
# most recent attempt for each of the workout's exercises is recorded
# in the scored_attempts relation.  The scored_attempts should always
# be a subset of the attempts.
#
# In the cases of a workout in the gym where there are no "offerings"
# (because they are free-practice, and not part of any course), then
# the workout_offering relationship would be null.  This is why there
# is both a workout relationship and a workout_offering relationship.
# When the workout_offering is provided, the workout relationship is
# redundant.  However, in cases where no workout_offering is present
# (because there is no course), then the workout relationship is needed.
#
# Note that one user may have only one WorkoutScore for a given
# workout offering, which represents that user's score on that
# workout offering.  However, one user may have /multiple/ workout score
# objects for the same workout, in the situation where the user repeats
# the workout multiple times.  One situation where this might happen is
# when the workout is in the gym and not associated with any course--the
# student might retake a workout they have previously completed.  Another
# situation is when one user takes a course and completes a workout as
# one assignment in the course; later that same student fails the course
# and must repeat it, and the second time around has to complete the
# same assignment again in a later term (as part of a separate course
# offering, meaning a second workout offering of the same workout).
# We want to support all of these situations.
#
class WorkoutScore < ActiveRecord::Base

  #~ Relationships ............................................................

  belongs_to :workout, inverse_of: :workout_scores
  belongs_to :workout_offering, inverse_of: :workout_scores
  belongs_to :user, inverse_of: :workout_scores
  has_many :attempts, inverse_of: :workout_score, dependent: :nullify
  has_many :scored_attempts, class_name: 'Attempt',
    foreign_key: 'active_score_id', inverse_of: :active_score,
    dependent: :nullify


  #~ Validation ...............................................................

  validates :workout, presence: true
  validates :user, presence: true


  #~ Instance methods .........................................................

  # -------------------------------------------------------------
  def update_attempt(attempt, old_score)
    if self.scored_attempts.include? attempt
      self.score = self.score - old_score + attempt.score
    else
      # look for other scored attempt for the same exercise
      scored = self.scored_attempts.includes(exercise_versions: :exercise).
        where(exercise: attempt.exercise_version.exercise).first
      if scored
        self.score -= scored.score
        self.scored_attempts.delete(scored)
      end
      self.score += attempt.score
      self.scored_attempts << attempt
    end
    self.save!
  end
  
  # -------------------------------------------------------------
  # (Finall) The refactored method to record the workout score
  # when a workout's exercise has been attempted
  def self.record_workout_score(score, exer, wkt_id,current_user)
    scoring = WorkoutScore.find_by(
      user: current_user, workout_id: wkt_id)
    @current_workout = Workout.find(wkt_id)
    exercise_version = exer.current_version
    
    # FIXME: This code repeats code in code_worker.rb and needs to be
    # refactored, probably as a method (or constructor?) in WorkoutScore.
    if scoring.nil?
      puts "SCORING NOT THERE","SCORING ALREADY THERE"
      scoring = WorkoutScore.new
      scoring.score = score
      scoring.last_attempted_at = Time.now
      scoring.exercises_completed = 1
      scoring.exercises_remaining = @current_workout.exercises.length - 1
      @current_workout.workout_scores << scoring
      current_user.workout_scores << scoring

    else # At least one exercise has been attempted as a part of the workout
      user_exercise_score =
        Attempt.user_attempt(current_user, exercise_version).andand.score
      puts "SCORED","ALREAD SCORED","ALREADY SCORED"  
      scoring.score += score
      scoring.last_attempted_at = Time.now
      if user_exercise_score
        scoring.score -= user_exercise_score
      else
        scoring.exercises_completed += 1
        scoring.exercises_remaining -= 1
        # Compensate if overshoots
        if scoring.exercises_completed > @current_workout.exercises.length
          scoring.exercises_completed = @current_workout.exercises.length
        end
        if scoring.exercises_remaining < 0
          scoring.exercises_remaining = 0
        end
        if scoring.exercises_remaining == 0
          scoring.completed = true
          scoring.completed_at = Time.now
        end
      end

    end
    scoring.save!
  end
  
end
