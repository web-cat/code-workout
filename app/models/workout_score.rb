# == Schema Information
#
# Table name: workout_scores
#
#  id                  :integer          not null, primary key
#  workout_id          :integer          not null
#  user_id             :integer          not null
#  score               :float(24)
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
  def closed?
    minutes_open = (Time.zone.now - self.created_at)/60.0
    time_limit = workout_offering.time_limit_for(user)

    !time_limit.nil? && minutes_open >= time_limit
  end

  # -------------------------------------------------------------
  # Increase the score of a workout by a specified amount 
  def rescore(delta)
    self.score += delta
    self.score = self.score.round(2)
    self.save! 
  end

  # -------------------------------------------------------------
  def time_remaining
    minutes_open = (Time.zone.now - self.created_at)/60.0
    time_limit = workout_offering.andand.time_limit_for(user)

    if time_limit.nil?
      nil
    else
      time_limit - minutes_open
    end
  end


  # -------------------------------------------------------------
  def show_feedback?
    if self.workout_offering &&
      self.workout_offering.hard_deadline_for(self.user) < Time.zone.now
      # !workout_offering.andand.workout_policy.andand.hide_feedback_in_review_after_close
      true
    elsif closed?
      !workout_offering.andand.workout_policy.andand.hide_feedback_in_review_before_close
    else
      !workout_offering.andand.workout_policy.andand.hide_feedback_before_finish
    end
  end


  # -------------------------------------------------------------
  def attempt_for(exercise)
    workout_score = self
    Attempt.joins{exercise_version}.
      where{(active_score_id == workout_score.id) &
      (exercise_version.exercise_id == exercise.id)}.first
  end


  # -------------------------------------------------------------
  def update_attempt(attempt, old_score)
    if self.scored_attempts.include? attempt
      self.score = self.score - old_score + attempt.score
      self.score = self.score.round(2)
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
    self.score = self.score.round(2)
    self.save!
  end


  # -------------------------------------------------------------
  def record_attempt(attempt)
    value = attempt.score
    last_attempt = self.scored_attempts.
      where(exercise_version: attempt.exercise_version).first
    if last_attempt
      last_attempt.active_score_id = nil
      last_attempt.save!
    else
      if self.exercises_completed < self.workout.exercises.length
        self.exercises_completed += 1
      end
      if self.exercises_remaining > 0
        self.exercises_remaining -= 1
      end
    end
    self.score = 0.00
    Attempt.where(active_score_id: self.id).each do |att|
      self.score += att.score
    end
    self.score += value
    attempt.active_score = self
    attempt.save!
    self.score = self.score.round(2)
    self.last_attempted_at = Time.zone.now

    if self.exercises_remaining == 0
      self.completed = true
      self.completed_at = Time.zone.now
    end

    self.save!
  end


  # ------------------------------------------------------------
  # Class method to fix all workout scores using round(2) on the
  # score obtained from Attempt using active score.
  def self.score_fix
    WorkoutScore.all.each do |ws|
      sum = 0.0
      ws.scored_attempts.each do |att|
        sum += att.score
      end
      ws.score = sum.round(2)
      if !ws.save
        puts "cannot save ws = #{ws.inspect}"
      end
    end
  end


  # -------------------------------------------------------------
  # (Final) The refactored method to record the workout score
  # when a workout's exercise has been attempted
  def self.record_workout_score(score, exer, wkt_id, current_user)
    self.fail # this method needs to go away and be replaced by
              # a better instance method
    scoring = nil
    if current_user && current_user.current_workout_score &&
      current_user.current_workout_score.workout.id = wkt_id
      scoring = current_user.current_workout_score
    end
    @current_workout = Workout.find(wkt_id)
    if scoring.nil? && current_user
      scoring = @current_workout.score_for(current_user)
    end
    exercise_version = exer.current_version
    score = score.round(2)
    # FIXME: This code repeats code in code_worker.rb and needs to be
    # refactored, probably as a method (or constructor?) in WorkoutScore.
    if scoring.nil?
      scoring = WorkoutScore.new(
        score: score,
        exercises_completed: 1,
        exercises_remaining: @current_workout.exercises.length - 1)
      @current_workout.workout_scores << scoring
      current_user.workout_scores << scoring
      if current_user
        scoring.save!
        current_user.current_workout_score = scoring
        current_user.save!
      end

    else # At least one exercise has been attempted as a part of the workout
      last_attempt = scoring.scored_attempts.
        where(exercise_version: exercise_version).first
      if last_attempt
        scoring.score -= last_attempt.score.round(2)
        last_attempt.active_scored_id = nil
        last_attempt.save!
      else
        scoring.exercises_completed += 1
        scoring.exercises_remaining -= 1
      end
      scoring.score += score.round(2)
    end
    scoring.last_attempted_at = Time.zone.now
    # Compensate if overshoots
    if scoring.exercises_completed > @current_workout.exercises.length
      scoring.exercises_completed = @current_workout.exercises.length
    end
    if scoring.exercises_remaining < 0
      scoring.exercises_remaining = 0
    end
    if scoring.exercises_remaining == 0
      scoring.completed = true
      scoring.completed_at = Time.zone.now
    end

    scoring.save!
  end

end
