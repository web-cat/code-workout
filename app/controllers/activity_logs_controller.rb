# app/controllers/activity_logs_controller.rb
# frozen_string_literal: true

class ActivityLogsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!

  # -------------------------------------------------------------
  # GET /activity_logs
  # Search & lookup page for arbitrary student activity logs across gym and courses
  def index
    @workout_scores = WorkoutScore.includes(:user, :workout, workout_offering: { course_offering: [:course, :term] })
                                  .joins(:user, :workout)

    has_filter = false

    if params[:student].present?
      has_filter = true
      term = params[:student].to_s.strip.downcase
      if term =~ /\A\d+\z/
        @workout_scores = @workout_scores.where(
          'users.id = ? OR lower(users.email) LIKE ? OR lower(users.first_name) LIKE ? OR lower(users.last_name) LIKE ?',
          term.to_i, "%#{term}%", "%#{term}%", "%#{term}%"
        )
      else
        @workout_scores = @workout_scores.where(
          'lower(users.email) LIKE ? OR lower(users.first_name) LIKE ? OR lower(users.last_name) LIKE ?',
          "%#{term}%", "%#{term}%", "%#{term}%"
        )
      end
    end

    if params[:workout].present?
      has_filter = true
      w_term = params[:workout].to_s.strip.downcase
      @workout_scores = @workout_scores.where('lower(workouts.name) LIKE ?', "%#{w_term}%")
    end

    if params[:scope] == 'gym'
      has_filter = true
      @workout_scores = @workout_scores.where(workout_offering_id: nil)
    elsif params[:scope] == 'course'
      has_filter = true
      @workout_scores = @workout_scores.where.not(workout_offering_id: nil)
    end

    @workout_scores = @workout_scores.order(updated_at: :desc).limit(50)
    @searched = has_filter
  end

  # -------------------------------------------------------------
  # GET /activity_logs/:id
  # Displays the detailed event timeline for a specific WorkoutScore
  def show
    @workout_score = WorkoutScore.find(params[:id])
    @student = @workout_score.user
    @workout = @workout_score.workout
    @workout_offering = @workout_score.workout_offering
    @course_offering = @workout_offering.andand.course_offering
    @exercise_id = params[:exercise_id]
    @exercise = Exercise.find_by(id: @exercise_id) if @exercise_id.present?

    # Fetch events associated with this workout score or user/workout
    @activity_logs = ActivityLog.where(workout_score: @workout_score)
    if @workout_offering.present?
      @activity_logs = @activity_logs.or(ActivityLog.where(workout_offering: @workout_offering, user: @student))
    else
      @activity_logs = @activity_logs.or(ActivityLog.where(workout: @workout, user: @student, workout_offering_id: nil))
    end
    @attempts = Attempt.where(workout_score: @workout_score)
    @visualization_loggings = VisualizationLogging.where(workout_score: @workout_score)

    if @exercise_id.present?
      @activity_logs = @activity_logs.where(exercise_id: @exercise_id)
      @attempts = @attempts.joins(:exercise_version).where(exercise_versions: { exercise_id: @exercise_id })
      @visualization_loggings = @visualization_loggings.where(exercise_id: @exercise_id)
    end

    # Combine and sort events
    @events = []

    @activity_logs.each do |log|
      @events << {
        type: 'activity',
        time: log.created_at,
        activity: log.activity,
        ip: log.ip_address,
        user_agent: log.respond_to?(:user_agent) ? log.user_agent : nil,
        lti: log.lti_launch,
        details: log
      }
    end

    @attempts.each do |attempt|
      @events << {
        type: 'attempt',
        time: attempt.submit_time || attempt.created_at,
        activity: 'evaluated',
        score: attempt.score,
        ip: attempt.ip_address,
        user_agent: attempt.respond_to?(:user_agent) ? attempt.user_agent : nil,
        lti: attempt.lti_launch,
        details: attempt
      }
    end

    @visualization_loggings.each do |log|
      @events << {
        type: 'visualization',
        time: log.created_at,
        activity: 'visualized',
        ip: log.ip_address,
        lti: log.lti_launch,
        details: log
      }
    end

    @events.sort_by! { |e| e[:time] || Time.zone.at(0) }.reverse!

    render 'workout_offerings/activity_log'
  end

  private

  # -------------------------------------------------------------
  def authorize_admin!
    unless current_user.andand.global_role.andand.is_admin? || current_user.andand.global_role.andand.can_edit_system_configuration?
      redirect_to root_path, alert: 'You are not authorized to view this page.'
    end
  end
end
