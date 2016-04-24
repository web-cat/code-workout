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
  has_many :attempts,
    -> { order('submit_time desc') },
    inverse_of: :workout_score,
    dependent: :nullify
  has_many :scored_attempts,
    -> { order('submit_time desc') },
    class_name: 'Attempt',
    foreign_key: 'active_score_id',
    inverse_of: :active_score,
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
    self.transaction do
      if attempt.workout_score == self
        # recalculate workout score
        self.score = 0.0
        self.scored_attempts.each do |att|
          self.score += att.score
        end
        self.score = self.score.round(2)
        self.save!
      end
    end
  end


  # -------------------------------------------------------------
  def record_attempt(attempt)
    self.transaction do
      scored_for_this = self.scored_attempts.
        where(exercise_version: attempt.exercise_version)
      last_attempt = scored_for_this.first

      # Only update if this attempt is included in score
      if last_attempt.nil? ||
        last_attempt.submit_time < attempt.submit_time

        if last_attempt
          # clear previous active score
          scored_for_this.each do |a|
            a.active_score_id = nil
            a.save!
          end
        else
          # update number of exercises completed
          if self.exercises_completed < self.workout.exercises.length
            self.exercises_completed += 1
          end
          if self.exercises_remaining > 0
            self.exercises_remaining -= 1
            if self.exercises_remaining == 0
              self.completed = true
              self.completed_at = Time.zone.now
            end
          end
        end

        # record new active score
        attempt.active_score = self
        attempt.save!

        # recalculate workout score
        self.score = 0.0
        self.scored_attempts.each do |a|
          self.score += a.score
        end
        self.score += attempt.score
        self.score = self.score.round(2)
        self.last_attempted_at = attempt.submit_time
        self.save!
      end
    end
  end


  # ------------------------------------------------------------
  # Class method to fix all workout scores using round(2) on the
  # score obtained from Attempt using active score.
  def self.score_fix
    WorkoutScore.all.each do |ws|
      ws.attempts.where(active_score: ws).each do |a|
        a.active_score_id = nil
        if !a.save
          puts "Error clearing scored attempt #{a.id} for ws #{ws.id}"
        end
      end
      ws.workout.exercises.each do |e|
        a = ws.attempts.joins{exercise_version}.
          where{(exercise_version.exercise_id == e.id)}.
          order('submit_time DESC').first
        if a
          a.active_score = ws
          if !a.save
            puts "Error saving scored attempt #{a.id} for ws #{ws.id}"
          end
        end
      end

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

end
