# == Schema Information
#
# Table name: workout_scores
#
#  id                      :integer          not null, primary key
#  workout_id              :integer          not null
#  user_id                 :integer          not null
#  score                   :float(24)
#  completed               :boolean
#  completed_at            :datetime
#  last_attempted_at       :datetime
#  exercises_completed     :integer
#  exercises_remaining     :integer
#  created_at              :datetime
#  updated_at              :datetime
#  workout_offering_id     :integer
#  lis_outcome_service_url :string(255)
#  lis_result_sourcedid    :string(255)
#  lti_workout_id          :integer
#
# Indexes
#
#  index_workout_scores_on_lti_workout_id  (lti_workout_id)
#  index_workout_scores_on_user_id         (user_id)
#  index_workout_scores_on_workout_id      (workout_id)
#  workout_scores_workout_offering_id_fk   (workout_offering_id)
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
  belongs_to :lti_workout, inverse_of: :workout_scores
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
    if !workout_offering
      return false
    end

    now = Time.zone.now
    minutes_open = (now - self.created_at)/60.0
    time_limit = workout_offering.time_limit_for(user)
    hard_deadline = workout_offering.hard_deadline_for(user)

    (time_limit && self.created_at && minutes_open >= time_limit) ||
        (hard_deadline && now > hard_deadline)
  end

  # -------------------------------------------------------------
  # Increase the score of a workout by a specified amount
  # FIXME: misnamed method.  Used in ExerciseVersion code, though.
  def rescore(delta)
    self.score += delta
    self.score = self.score.round(2)
    self.save!
  end

  # -------------------------------------------------------------
  def time_remaining
    if !workout_offering
      nil
    end
    time_limit = workout_offering.andand.time_limit_for(user)

    if time_limit
      now = Time.zone.now
      remaining = time_limit - (now - self.created_at)/60.0
      hard_deadline = workout_offering.hard_deadline_for(user)

      if hard_deadline
        until_deadline = (hard_deadline - now)/60.0
      end

      # return the lesser of the two possible limits
      if until_deadline
        return [remaining, until_deadline].min
      else
        return remaining
      end
    else
      nil
    end
  end


  # -------------------------------------------------------------
  def show_feedback?
    if !self.workout_offering
      return true
    end

    if self.closed?
      if workout_offering.shutdown?
        # FIXME: ???
        # true
        !workout_offering.andand.workout_policy.andand.hide_feedback_in_review_before_close
      else
        !workout_offering.andand.workout_policy.andand.hide_feedback_in_review_before_close
      end
    else
      !workout_offering.andand.workout_policy.andand.hide_feedback_before_finish
    end
  end

  # -------------------------------------------------------------
  def attempts_left_for_exercise_version(exercise_version)
    if self.workout_offering.andand.attempt_limit
      attempts_made = self
        .attempts
        .where(exercise_version: exercise_version)
        .count
      return self.workout_offering.attempt_limit - attempts_made
    end

    return nil
  end

  # -------------------------------------------------------------
  def scoring_attempt_for(exercise)
    workout_score = self
    Attempt.joins{exercise_version}.
      where{(active_score_id == workout_score.id) &
      (exercise_version.exercise_id == exercise.id)}.first
  end


  # -------------------------------------------------------------
  def previous_attempt_for(exercise)
    attempts.joins{exercise_version}.
      where{exercise_version.exercise_id == exercise.id}.first
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
    self.with_lock do
      # scored_for_this = self.scored_attempts.joins{exercise_version}.
      #  where{(exercise_version.exercise_id == e.id)}
      scored_for_this = self.scored_attempts.
        where(exercise_version: attempt.exercise_version)

      last_attempt = scored_for_this.first

      record_score = last_attempt ? (
        (self.workout_offering.andand.most_recent) ?
          (attempt.submit_time > last_attempt.submit_time) :
          (attempt.score > last_attempt.score ||
          (attempt.score == last_attempt.score &&
          attempt.submit_time > last_attempt.submit_time))) :
        true

      # Only update if this attempt is included in score
      if record_score
        if last_attempt
          # clear previous active score
          scored_for_this.each do |a|
            self.scored_attempts.delete(a)
          end
        else
          # update number of exercises completed
          if self.exercises_completed &&
              self.exercises_completed < self.workout.exercises.length
            self.exercises_completed += 1
          end
          if self.exercises_remaining && self.exercises_remaining > 0
            self.exercises_remaining -= 1
            if self.exercises_remaining == 0
              self.completed = true
              self.completed_at = attempt.submit_time
            end
          end
        end

        self.scored_attempts << attempt
        self.save!
        recalculate_score!(attempt: attempt)
      end
    end
  end

  def recalculate_score!(options = {})
    self.with_lock do
      attempt = options[:attempt]
      self.score = 0.0
      self.scored_attempts.each do |a|
        self.score += a.score
      end
      self.score = self.score.round(2)
      if attempt && (!self.last_attempted_at ||
        self.last_attempted_at < attempt.submit_time)
        self.last_attempted_at = attempt.submit_time
      end
      self.save!

      if self.lis_outcome_service_url && self.lis_result_sourcedid
        update_lti
      end
    end
  end


  # ------------------------------------------------------------
  # Completely recalculate the current score from scratch
  def retotal
    self.transaction do

      # Clear all active scores
      self.scored_attempts.clear

      # Clear the total score
      self.score = 0.0
      self.exercises_completed = 0
      self.exercises_remaining = self.workout.exercises.count
      self.save!

      # Re-record every attempt, which should correctly set the
      # active score for each exercise, and recompute the total score
      self.attempts.each do |a|
        if a.feedback_ready
          self.record_attempt(a)
        end
      end
    end
  end


  # ------------------------------------------------------------
  # Class method to find workout scores that were computed after
  # they were closed. Outputs a list of workout scores.
  def self.late(options={})
    WorkoutScore.joins{ workout_offering }
      .joins('inner join student_extensions on student_extensions.workout_offering_id = workout_offerings.id
             and student_extensions.user_id = workout_scores.user_id')
      .where('workout_scores.last_attempted_at > 
        coalesce(student_extensions.hard_deadline, workout_offerings.hard_deadline, "2030-12-31")')
  end


  # ------------------------------------------------------------
  # Class method to fix all workout scores by ensuring there is only
  # a single active score attempt for each unique exercise attempted.
  def self.score_fix1
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


  # ------------------------------------------------------------
  # Class method to fix all workout scores using round(2) on the
  # score obtained from Attempt using active score.
  def self.score_fix2
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


  # ------------------------------------------------------------
  # Class method to fix all workout scores by ensuring there is only
  # a single active score attempt for each unique exercise attempted.
  def self.retotal_for(workout_offering_id)
    scores = WorkoutScore.where(workout_offering_id: workout_offering_id)
    scores.each do |ws|
      ws.retotal
    end
  end


  # ------------------------------------------------------------
  def self.grade_unprocessed_attempts(exercise_version_id)
    attempts = Attempt.where(
      exercise_version_id: exercise_version_id, feedback_ready: nil)
    attempts.each do |a|
      if a.workout_score
        # This "regrade" is done synchronously, since it is probably done
        # interactively from the rails console, and we want to wait for each
        # to be done, not just flood a queue and then quit.
        CodeWorker.new.perform(a.id)
        puts "#{a.id} => #{a.score}"
      end
    end
  end

  # Sends scores to the appropriate LTI consumer
  # -------------------------------------------------------------
  def update_lti
    if self.workout_offering
      lms_instance = self.workout_offering.course_offering.lms_instance
    elsif self.lti_workout
      lms_instance = self.lti_workout.lms_instance
    end

    if lms_instance && self.lis_outcome_service_url && self.lis_result_sourcedid
      total_points = ExerciseWorkout.where(workout_id: self.workout_id).sum(:points)
      key = lms_instance.consumer_key
      secret = lms_instance.consumer_secret

      result = total_points > 0 ? self.score / total_points : 0
      tp = IMS::LTI::ToolProvider.new(key, secret, {
        "lis_outcome_service_url" => "#{self.lis_outcome_service_url}",
        "lis_result_sourcedid" => "#{self.lis_result_sourcedid}"
      })
      tp.post_replace_result!(result)
    end
  end
end
