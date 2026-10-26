# == Schema Information
#
# Table name: workouts
#
#  id                :bigint           not null, primary key
#  description       :text(65535)
#  is_public         :boolean
#  name              :string(255)      not null
#  points_multiplier :integer
#  scrambled         :boolean          default(FALSE)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  creator_id        :bigint
#  external_id       :string(255)
#
# Indexes
#
#  index_workouts_on_external_id  (external_id) UNIQUE
#  index_workouts_on_is_public    (is_public)
#  workouts_creator_id_fk         (creator_id)
#
# Foreign Keys
#
#  workouts_creator_id_fk  (creator_id => users.id)
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
class Workout < ApplicationRecord
  #~ Relationships ............................................................

  acts_as_taggable_on :tags, :languages, :styles
	has_many :exercise_workouts,
	  -> { includes(:exercise).order('position ASC') },
	  inverse_of: :workout, dependent: :destroy
  has_many :exercises, through: :exercise_workouts
  has_many :legacy_exercises, through: :exercise_workouts, source: :exercise
  has_many :exercise_pools,
    -> { order('exercise_pools.position ASC') },
    inverse_of: :workout, dependent: :destroy
  has_many :exercise_pool_items, through: :exercise_pools
  has_many :pooled_exercises, -> { distinct }, through: :exercise_pool_items, source: :exercise
	has_many :workout_scores, inverse_of: :workout, dependent: :destroy
  has_many :users, through: :workout_scores
  has_many :attempts
  has_many :workout_offerings, inverse_of: :workout, dependent: :destroy
  has_many :course_offerings, through:  :workout_offerings
  has_many :courses, through: :course_offerings
  belongs_to :creator, class_name: 'User'
  has_many :workout_owners, inverse_of: :workout, dependent: :destroy
  has_many :owners, through: :workout_owners
  has_many :lti_workouts

  accepts_nested_attributes_for :exercise_workouts
  accepts_nested_attributes_for :exercise_pools, allow_destroy: true
  accepts_nested_attributes_for :workout_offerings

  # -------------------------------------------------------------
  # Setter for exercises to maintain backwards compatibility with existing
  # factories and assignment patterns, syncing both exercise_workouts and exercise_pools.
  def exercises=(new_exercises)
    new_exercises = Array(new_exercises).compact
    self.exercise_workouts = new_exercises.each_with_index.map do |ex, idx|
      ExerciseWorkout.new(workout: self, exercise: ex, position: idx + 1, points: 1.0)
    end
    self.exercise_pools = new_exercises.each_with_index.map do |ex, idx|
      pool = ExercisePool.new(workout: self, position: idx + 1, select_count: 1, points: 1.0)
      pool.exercise_pool_items.build(exercise: ex, position: 1)
      pool
    end
  end

  # -------------------------------------------------------------
  # Returns the workout policy of the first offering of this workout, or the default.
  def workout_policy
    workout_offerings.first.andand.workout_policy || WorkoutPolicy.default
  end


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

  paginates_per 40

  #~ Class methods ............................................................
  def self.visible_to_user(user)
    return Workout.where(creator_id: user.id).or(Workout.where(is_public: true))
  end

  # -------------------------------------------------------------
  # Finds a workout by numeric ID or by name / parameterized name.
  # If a course and term are provided, it searches workouts offered
  # in that course and term before falling back to global lookup.
  def self.find_by_id_or_name(id_or_name, course = nil, term = nil)
    return nil if id_or_name.blank?

    # 1. If purely numeric, find by primary key ID
    if id_or_name.to_s =~ /\A\d+\z/
      w = Workout.find_by(id: id_or_name)
      return w if w
    end

    idparam = id_or_name.to_s.downcase

    # 2. If course and term are provided, search workouts offered in that course/term
    if course && term
      offerings = WorkoutOffering.joins(:course_offering).where(
        course_offerings: { course_id: course.id, term_id: term.id }
      ).includes(:workout)
      w = offerings.map(&:workout).compact.uniq.find do |workout|
        wname = workout.name.downcase
        wparam = workout.name.downcase.parameterize
        idparam == wname || idparam == wparam
      end
      return w if w
    end

    # 3. Fallback: search by exact or case-insensitive name globally
    Workout.where('lower(name) = ?', idparam).first ||
      Workout.all.find { |workout| workout.name.downcase.parameterize == idparam }
  end

  # -------------------------------------------------------------
  # Finds the appropriate WorkoutOffering for a user in a course and term.
  # Checks student enrolled sections first, then instructor managed sections,
  # and finally falls back to any offering for this workout in the course/term.
  def workout_offering_for(user, course, term)
    return nil unless course && term

    if user
      enrolled_offerings = user.course_offerings_for_term(term, course)
      if enrolled_offerings.any?
        wo = WorkoutOffering.where(
          course_offering_id: enrolled_offerings.map(&:id),
          workout_id: self.id
        ).first
        return wo if wo
      end

      managed_offerings = user.managed_course_offerings(course: course, term: term)
      if managed_offerings.any?
        wo = WorkoutOffering.where(
          course_offering_id: managed_offerings.map(&:id),
          workout_id: self.id
        ).first
        return wo if wo
      end
    end

    WorkoutOffering.joins(:course_offering).where(
      course_offerings: { course_id: course.id, term_id: term.id },
      workout_id: self.id
    ).first
  end


  # -------------------------------------------------------------
  # Creates a new workout with the specified descriptive parameters and
  # populates it with all exercises from the specified list of workout IDs.
  # Exercises are copied in the order of the provided workout IDs, preserving
  # their original order and points, and skipping duplicate exercises.
  #
  # @param params [Hash, ActionController::Parameters] Attributes for the new workout
  #   (e.g., :name, :description, :creator, :is_public, :scrambled, etc.)
  # @param workout_ids [Array<Integer, String>] Array of workout IDs to copy exercises from
  # @return [Workout] The created workout (persisted if valid)
  #
  # @example Create a new combined workout from existing workouts
  #   new_workout = Workout.create_from_workouts(
  #     {
  #       name: 'Combined Unit Review',
  #       description: 'Exercises from workouts 10, 12, and 15',
  #       creator: current_user,
  #       is_public: true
  #     },
  #     [10, 12, 15]
  #   )
  #
  def self.create_from_workouts(params, workout_ids = [])
    # Support flexible argument order: (workout_ids, params) or (params, workout_ids)
    if params.is_a?(Array) && workout_ids.is_a?(Hash)
      workout_ids, params = params, workout_ids
    end

    workout = Workout.new(params)

    transaction do
      if workout.save
        position = 1
        seen_exercise_ids = Set.new

        # Preserve the sequence of workouts as passed in workout_ids
        source_workouts = Workout.where(id: workout_ids).index_by(&:id)
        ordered_workouts = Array(workout_ids).map { |id| source_workouts[id.to_i] }.compact

        ordered_workouts.each do |source_workout|
          source_workout.exercise_workouts.order(:position).each do |ew|
            next if seen_exercise_ids.include?(ew.exercise_id)
            seen_exercise_ids.add(ew.exercise_id)

            ExerciseWorkout.create!(
              workout: workout,
              exercise_id: ew.exercise_id,
              points: ew.points,
              position: position
            )
            position += 1
          end
        end
      end
    end

    workout
  end


  #~ Instance methods .........................................................

  # Workout is visible if the user is the creator or
  # if the workout is public
  def visible_to?(user)
    self.is_public || self.creator == user
  end

  # -------------------------------------------------------------
  # FIXME: probably shouldn't be here, since it omits setting the
  # point value.
  def add_exercise(ex)
    self.exercise_workouts <<
      ExerciseWorkout.new(workout: self, exercise: ex)
  end


  # -------------------------------------------------------------
  # return the totals points of the exercises in the current workout.
  def total_points
    if (exercise_pools.loaded? ? exercise_pools.any? : exercise_pools.exists?)
      exercise_pools.sum { |pool| (pool.select_count || 1) * (pool.points || 0.0) }.to_f
    elsif exercise_workouts.loaded?
      exercise_workouts.map { |ew| ew.points || 0 }.sum.to_f
    else
      exercise_workouts.pluck(:points).compact.sum.to_f
    end
  end


  # -------------------------------------------------------------
  # Simple method to return the number of exercises a workout has
  def num_exercises
    if (exercise_pools.loaded? ? exercise_pools.any? : exercise_pools.exists?)
      exercise_pools.sum { |pool| pool.select_count || 1 }
    else
      self.exercises.length
    end
  end


  # -------------------------------------------------------------
  def contains?(exercise)
    if (exercise_pools.loaded? ? exercise_pools.any? : exercise_pools.exists?)
      exercise_pool_items.where(exercise: exercise).any?
    else
      self.exercise_workouts.where(exercise: exercise).any?
    end
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
  def first_exercise(workout_score = nil)
    if workout_score && workout_score.workout_score_exercises.any?
      return workout_score.workout_score_exercises.order(:position).first&.exercise
    end

    if (exercise_pools.loaded? ? exercise_pools.any? : exercise_pools.exists?)
      first_pool = exercise_pools.order(:position).first
      first_pool&.exercises&.first || exercise_workouts.first&.exercise
    else
      exercise_workouts.first&.exercise
    end
  end

  # ------------------------------------------------------------
  # Given a current exercise, get the next exercise in the
  # workout. Return the first exercise if the current exercise
  # is `nil`. Return the first exercise if the current exercise
  # does not belong to this workout.
  #
  # @param ex            The current exercise in the workout.
  # @param workout_score Optional attempt snapshot to navigate within
  def next_exercise(ex, workout_score = nil)
    if workout_score && workout_score.workout_score_exercises.any?
      wse = workout_score.workout_score_exercises.find_by(exercise: ex)
      if wse
        next_wse = workout_score.workout_score_exercises.where('position > ?', wse.position).order(:position).first
        return next_wse.exercise if next_wse
      end
      return first_exercise(workout_score)
    end

    if (exercise_pools.loaded? ? exercise_pools.any? : exercise_pools.exists?)
      current_item = ExercisePoolItem.joins(:exercise_pool).where(exercise_pools: { workout_id: id }, exercise_id: ex&.id).first
      if current_item
        current_pool = current_item.exercise_pool
        next_in_pool = current_pool.exercise_pool_items.where('position > ?', current_item.position).order(:position).first
        return next_in_pool.exercise if next_in_pool

        next_pool = exercise_pools.where('position > ?', current_pool.position).order(:position).first
        return next_pool.exercises.first if next_pool && next_pool.exercises.any?
      end
    end

    ew = nil
    if ex
      ew = exercise_workouts.where(exercise: ex).first
    end
    if ew
      ew = ew.lower_item
    end
    return ew.andand.exercise || first_exercise
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
    exs = exercises.loaded? ? exercises : exercises.includes(:irt_data)
    exs.each do |x|
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
  # Save this workout with the specified params. Remove any
  # exercises that have been marked for removal.
  # @param params   A hash of workout params for this workout
  # -------------------------------------------------------------
  # Save this workout with the specified params. Accepts either `pools`
  # (array of pool slot definitions) or legacy `exercises` (array of exercises).
  # @param params   A hash of workout params for this workout
  def update_or_create(params)
    self.name = params[:name]
    self.description = params[:description]
    self.is_public = params[:is_public]

    was_new_record = new_record?

    # 1. Save parent record first so foreign keys are valid for child records
    return false unless self.save

    begin
      # 2. Handle LTI workout associations if provided
      if params[:lms_assignment_id].present?
        lti_workout = LtiWorkout.find_by(lms_assignment_id: params[:lms_assignment_id])
        if !lti_workout
          lti_workout = LtiWorkout.create(
            lms_assignment_id: params[:lms_assignment_id],
            lms_instance: LmsInstance.find(params[:lms_instance_id]),
            workout: self
          )
        end
      end

      # 3. Synchronize exercise pools or legacy exercises
      if params[:pools].present?
        raw_pools = params[:pools].is_a?(String) ? JSON.parse(params[:pools]) : params[:pools]
        reconcile_exercise_pools!(raw_pools)
      elsif params[:exercises].present?
        removed_exercises = params[:removed_exercises].present? ? (params[:removed_exercises].is_a?(String) ? JSON.parse(params[:removed_exercises]) : params[:removed_exercises]) : []
        removed_exercises.each do |exercise_workout_id|
          self.exercise_workouts.destroy(exercise_workout_id) rescue nil
        end

        raw_exercises = params[:exercises].is_a?(String) ? JSON.parse(params[:exercises]) : params[:exercises]
        legacy_pools = raw_exercises.each_with_index.map do |ex, idx|
          {
            'position' => idx + 1,
            'select_count' => 1,
            'points' => ex['points'] || 1.0,
            'exercise_ids' => [ex['id']]
          }
        end
        reconcile_exercise_pools!(legacy_pools)
      end

      return self
    rescue => e
      logger.error "Workout#update_or_create failed: #{e.message}\n#{e.backtrace.join("\n")}" if respond_to?(:logger) && logger
      destroy if was_new_record && persisted?
      return false
    end
  end

  # -------------------------------------------------------------
  # Synchronizes ExercisePool and ExercisePoolItem records for this workout.
  def reconcile_exercise_pools!(pools_data)
    pools_data = Array(pools_data)
    current_pools = self.exercise_pools.to_a
    submitted_pool_ids = []

    pools_data.each_with_index do |pool_hash, idx|
      pool_id = pool_hash['id'].presence
      pool = if pool_id
        current_pools.find { |p| p.id.to_s == pool_id.to_s } || self.exercise_pools.build
      else
        self.exercise_pools.build
      end

      pool.position = pool_hash['position'].presence || (idx + 1)
      raw_k = pool_hash['select_count'] || pool_hash['k'] || 1
      pool.select_count = [raw_k.to_i, 1].max
      pool.points = pool_hash['points'].presence || 1.0
      pool.save!
      submitted_pool_ids << pool.id

      # Synchronize items
      raw_ids = pool_hash['exercise_ids'] || (pool_hash['exercises'] ? pool_hash['exercises'].map { |e| e['id'] } : [])
      candidate_ids = Array(raw_ids).reject(&:blank?).map(&:to_i).uniq

      # Remove items not in candidate_ids
      pool.exercise_pool_items.where.not(exercise_id: candidate_ids).destroy_all

      candidate_ids.each_with_index do |ex_id, item_idx|
        item = pool.exercise_pool_items.find_or_initialize_by(exercise_id: ex_id)
        item.position = item_idx + 1
        item.save!
      end

      # Ensure select_count does not exceed candidate count if items exist
      if candidate_ids.any? && pool.select_count > candidate_ids.size
        pool.update_column(:select_count, candidate_ids.size)
      end
    end

    # Destroy pools belonging to this workout that were removed
    self.exercise_pools.where.not(id: submitted_pool_ids).destroy_all

    # Explicitly enforce submitted positions (1..N) to prevent acts_as_list
    # shifting side-effects caused by inserting new records or destroying old ones.
    submitted_pool_ids.each_with_index do |pid, idx|
      self.exercise_pools.where(id: pid).update_all(position: idx + 1)
    end
    self.exercise_pools.reload

    # Synchronize legacy exercise_workouts for compatibility
    sync_exercise_workouts_from_pools!
  end

  # -------------------------------------------------------------
  # Keeps legacy exercise_workouts in sync with the current exercise_pools.
  def sync_exercise_workouts_from_pools!
    seen_ex_ids = []
    ew_position = 0

    exercise_pools.order(:position).each do |pool|
      pool.exercise_pool_items.order(:position).each do |item|
        next if seen_ex_ids.include?(item.exercise_id)
        seen_ex_ids << item.exercise_id
        ew_position += 1

        ew = exercise_workouts.find_or_initialize_by(exercise_id: item.exercise_id)
        ew.position = ew_position
        ew.points = pool.points
        ew.save!
      end
    end

    if seen_ex_ids.any?
      exercise_workouts.where.not(exercise_id: seen_ex_ids).destroy_all
      seen_ex_ids.each_with_index do |eid, idx|
        exercise_workouts.where(exercise_id: eid).update_all(position: idx + 1)
      end
    else
      exercise_workouts.destroy_all
    end
  end

  # ----------------------------------------------------------------------------
  # Updates or creates offerings for this workout in the specified courses.
  # The common hash contains options for each offering that are common among them.
  def add_workout_offerings(course_offerings, common)
    workout_offerings = [] # Workout offerings added from this submission.
    course_offerings.each do |id, offering|
      course_offering = CourseOffering.find(id)
      workout_offering = WorkoutOffering.find_by(workout: self,
                                                 course_offering: course_offering)
      if workout_offering.blank?
        workout_offering = WorkoutOffering.new
      end
      workout_offering.workout = self
      workout_offering.course_offering = course_offering
      workout_offering.time_limit = common[:time_limit]
      workout_offering.attempt_limit = common[:attempt_limit]
      workout_offering.published = common[:published]

      if offering.key?('workout_attempt_limit') || offering.key?('workout_attempts') || offering.key?('attempts')
        val = offering['workout_attempt_limit'] || offering['workout_attempts'] || offering['attempts']
        workout_offering.workout_attempt_limit = val.present? ? val.to_i : nil
      elsif common.key?(:workout_attempt_limit)
        workout_offering.workout_attempt_limit = common[:workout_attempt_limit]
      end

      if offering.key?('workout_score_to_keep') || offering.key?('score_to_keep')
        val = offering['workout_score_to_keep'] || offering['score_to_keep']
        workout_offering.workout_score_to_keep = val.presence
      elsif common.key?(:workout_score_to_keep) || common.key?(:score_to_keep)
        val = common[:workout_score_to_keep] || common[:score_to_keep]
        workout_offering.workout_score_to_keep = val.presence
      end

      # update workout scores so they follow the new policy
      offering_exercise_score = if offering.key?('exercise_score_to_keep')
                                  offering['exercise_score_to_keep']
                                elsif offering.key?('most_recent')
                                  offering['most_recent']
                                elsif common.key?(:exercise_score_to_keep)
                                  common[:exercise_score_to_keep]
                                elsif common.key?(:most_recent)
                                  common[:most_recent]
                                end
      if !offering_exercise_score.nil?
        val = offering_exercise_score.in?([true, 'true', 'latest', :latest]) ? 'latest' : 'highest'
        if workout_offering.new_record?
          workout_offering.exercise_score_to_keep = val
        elsif workout_offering.exercise_score_to_keep != val
          workout_offering.exercise_score_to_keep = val
          workout_offering.save!
          workout_offering.rescore_all
        end
      end

      if offering.key?('lms_assignment_url') || offering.key?('url')
        workout_offering.lms_assignment_url = offering['lms_assignment_url'] || offering['url']
      end

      # set deadlines
      workout_offering.opening_date = offering['opening_date'].present? ?
        DateTime.strptime(offering['opening_date'].to_s, '%Q') : nil
      workout_offering.soft_deadline = offering['soft_deadline'].present? ?
        DateTime.strptime(offering['soft_deadline'].to_s, '%Q') : nil
      workout_offering.hard_deadline = offering['hard_deadline'].present? ?
        DateTime.strptime(offering['hard_deadline'].to_s, '%Q') : nil

      workout_offering.workout_policy = common[:workout_policy]
      if offering.key?('allowed_ips') || offering.key?('ips')
        workout_offering.allowed_ips = offering['allowed_ips'] || offering['ips']
      end
      if offering.key?('allowed_user_agents') || offering.key?('user_agents') || offering.key?('browsers')
        workout_offering.allowed_user_agents = offering['allowed_user_agents'] || offering['user_agents'] || offering['browsers']
      end
      if common[:lms_assignment_id].present?
        workout_offering.lms_assignment_id = common[:lms_assignment_id]
      end
      if common[:lti_assignment_id].present?
        workout_offering.lti_assignment_id = common[:lti_assignment_id]
      end
      if common[:resource_link_id].present?
        workout_offering.resource_link_id = common[:resource_link_id]
      end
      if common[:lms_instance_id].present?
        workout_offering.lms_instance_id = common[:lms_instance_id]
      end
      workout_offering.save!
      workout_offerings << workout_offering.id
      extensions = offering['extensions'] || []
      extensions.each do |ext|
        student_id = ext['student_id']
        student = User.find(student_id)
        StudentExtension.create_or_update!(student, workout_offering, ext)
      end
    end

    return workout_offerings
  end


  # -------------------------------------------------------------
  def deep_clone!
    clone = self.dup
    clone.save
    self.exercises.each do |e|
      exercise_workout = ExerciseWorkout.new(workout: clone, exercise: e)
      exercise_workout.save
    end

    return clone
  end

  # -------------------------------------------------------------
  def score_for(user, workout_offering = nil,
                lis_outcome_service_url = nil, lis_result_sourcedid = nil)
    if workout_scores.loaded?
      scores = workout_scores.select do |s|
        s.user_id == user.andand.id && s.workout_offering_id == workout_offering.andand.id
      end.sort_by { |s| s.updated_at || Time.at(0) }.reverse

      if lis_outcome_service_url || lis_result_sourcedid
        scores.detect do |s|
          s.lis_outcome_service_url == lis_outcome_service_url &&
            s.lis_result_sourcedid == lis_result_sourcedid
        end
      else
        scores.first
      end
    else
      scores = workout_scores.where(
        user: user, workout_offering: workout_offering).order('updated_at DESC')
      if lis_outcome_service_url || lis_result_sourcedid
        scores.to_ary.detect do |s|
          s.lis_outcome_service_url == lis_outcome_service_url and
            s.lis_result_sourcedid == lis_result_sourcedid
        end
      else
        scores.first
      end
    end
  end


  #~ Class methods ............................................................

  # -------------------------------------------------------------
  def self.search(terms, user, course, searching_offerings)
    split_terms = terms.blank? ? '.' : terms.join('|')

    if user
      available_workouts = Workout.includes(:tags, :exercise_workouts, exercises: :irt_data).where(
        id: (Workout.visible_to_user(user).union(user.managed_workouts))
        .map(&:id)
      )

      # If a course is specified, we want the results sorted by terms in which
      # workouts were offered for that course.
      if course && user.is_a_member_of?(course.andand.user_group)
        workout_offerings = course.course_offerings.joins(:workout_offerings, :term)
          .order('terms.ends_on DESC')
          .flat_map(&:workout_offerings)
        if terms.blank?
          workouts_to_search = available_workouts
        else
          workouts_to_search = available_workouts.tagged_with(terms, any: true, wild: true, on: :tags) +
            available_workouts.tagged_with(terms, any: true, wild: true, on: :languages) +
            available_workouts.tagged_with(terms, any: true, wild: true, on: :styles)
          if split_terms
            workouts_to_search = workouts_to_search + available_workouts.where('name regexp (?)', split_terms)
          end
        end
        workouts_to_search = workouts_to_search.flat_map(&:id)

        workout_offerings = workout_offerings.select{ |wo| workouts_to_search.include?(wo.workout.id) }

        # workouts_with_term is of the form
        # [[CourseOffering, WorkoutOffering], [CourseOffering, WorkoutOffering], [CourseOffering, WorkoutOffering]]
        # we will convert it into a Hash where each key is a term, and each value is an array of Workouts
        # that were offered in that term
        if searching_offerings
          workouts_with_term = workout_offerings.map { |wo| [wo.course_offering.term, wo] }
          results = workouts_with_term.group_by(&:first)
            .map{ |k, a| [k, a.map(&:last)] }
          results = self.array_to_hash(results)
          results.each do |term, workout_offerings|
            results[term] = workout_offerings.uniq{ |wo| wo.workout }
          end
        else
          workouts_with_term = workout_offerings.map { |wo| [wo.course_offering.term, wo.workout] }
          results = workouts_with_term.group_by(&:first)
            .map{ |k, a| [k, a.map(&:last)] }
          results = self.array_to_hash(results)
          results.each do |term, workouts|
            results[term] = workouts.uniq
          end
        end
        return results
      end
    else
      available_workouts = Workout.includes(:tags, :exercise_workouts, exercises: :irt_data).where(is_public: true)
    end

    return available_workouts.tagged_with(terms, any: true, wild: true, on: :tags) +
      available_workouts.tagged_with(terms, any: true, wild: true, on: :languages) +
      available_workouts.tagged_with(terms, any: true, wild: true, on: :styles) +
      available_workouts.where('name regexp (?)', split_terms).distinct
  end


  #~ Private instance methods .................................................
  private

  # -------------------------------------------------------------
  # helper to convert array to hash
  # duplicated from ArrayHelper for the moment

  # Converts an array of the form
  # [[k1, val1],[k2, val2]] to a hash of the form
  # { k1: val, k2: val2}
  # val1 and val2 can be inner arrays
  #----------------------------------
  def self.array_to_hash(a)
    h = {}
    a.each do |i|
      key = i.first
      value = i.last
      h[key] = value
    end
    h
  end

end
