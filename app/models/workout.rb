# == Schema Information
#
# Table name: workouts
#
#  id                :integer          not null, primary key
#  name              :string(255)      default(""), not null
#  scrambled         :boolean          default(FALSE)
#  created_at        :datetime
#  updated_at        :datetime
#  description       :text(65535)
#  points_multiplier :integer
#  creator_id        :integer
#  external_id       :string(255)
#  is_public         :boolean
#
# Indexes
#
#  index_workouts_on_external_id  (external_id) UNIQUE
#  index_workouts_on_is_public    (is_public)
#  workouts_creator_id_fk         (creator_id)
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
	has_many :exercise_workouts,
	  -> { includes(:exercise).order('position ASC') },
	  inverse_of: :workout, dependent: :destroy
  has_many :exercises, through: :exercise_workouts
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
  scope :visible_to_user, -> (u) { where { (creator_id == u.id) | (is_public == true) } }

  # paginates_per 1


  #~ Class methods ............................................................

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
  def first_exercise
    exercise_workouts.first.exercise
  end

  # ------------------------------------------------------------
  def next_exercise(ex)
    ew = nil
    if ex
      ew = exercise_workouts.where(exercise: ex).first
    end
    if ew
      ew = ew.lower_item
    end
    if !ew
      ew = exercise_workouts.first
    end
    return ew.andand.exercise
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
    self.exercises.includes(:irt_data).references(:all).each do |x|
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
  
  def update_or_create(params)
      self.name = params[:name]
      self.description = params[:description]
      self.is_public = params[:is_public]

      if params[:lms_assignment_id].present?
        # if we don't have an lti workout, create it
        lti_workout = LtiWorkout.find_by(lms_assignment_id: params[:lms_assignment_id])
        if !lti_workout
          lti_workout = LtiWorkout.create(
            lms_assignment_id: params[:lms_assignment_id],
            lms_instance: LmsInstance.find(params[:lms_instance_id]),
            workout: self
          )
        end
      end

      removed_exercises = JSON.parse params[:removed_exercises]
      removed_exercises.each do |exercise_workout_id|
        self.exercise_workouts.destroy exercise_workout_id
      end
      exercises = JSON.parse params[:exercises]
      exercises.each_with_index do |ex, index|
        exercise = Exercise.find ex['id']
        exercise_workout =
          ExerciseWorkout.find_by workout: self, exercise: exercise
        if exercise_workout.blank?
          exercise_workout =
            ExerciseWorkout.new workout: self, exercise: exercise
        end
        exercise_workout.set_list_position(index+1)
        exercise_workout.points = ex['points']
        exercise_workout.save!
      end

      return self.save ? self : false 
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

      # update workout scores so they follow the new policy
      if common[:most_recent].to_b != workout_offering.most_recent
        workout_offering.most_recent = common[:most_recent]
        workout_offering.save!
        workout_offering.rescore_all
      end

      workout_offering.lms_assignment_url = offering['lms_assignment_url']

      # set deadlines
      if offering['opening_date'].present?
        workout_offering.opening_date =
          DateTime.strptime(offering['opening_date'].to_s, '%Q')
      end
      if offering['soft_deadline'].present?
        workout_offering.soft_deadline =
          DateTime.strptime(offering['soft_deadline'].to_s, '%Q')
      end
      if offering['hard_deadline'].present?
        workout_offering.hard_deadline =
          DateTime.strptime(offering['hard_deadline'].to_s, '%Q')
      end

      workout_offering.workout_policy = common[:workout_policy]
      if common[:lms_assignment_id].present?
        workout_offering.lms_assignment_id = common[:lms_assignment_id]
      end
      workout_offering.save!
      workout_offerings << workout_offering.id
      extensions = offering['extensions']
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
    if workout_offering && (lis_outcome_service_url || lis_result_sourcedid)
      workout_scores.where(
        user: user,
        workout_offering: workout_offering,
        lis_outcome_service_url: lis_outcome_service_url,
        lis_result_sourcedid: lis_result_sourcedid
      ).order('updated_at DESC').first
    elsif lis_outcome_service_url || lis_result_sourcedid
      workout_scores.where(
        user: user, 
        workout_offering: nil,
        lis_outcome_service_url: lis_outcome_service_url,
        lis_result_sourcedid: lis_result_sourcedid
      ).order('updated_at DESC').first
    elsif workout_offering # can assume that the first one is what we want
      workout_scores.where(
        user: user,
        workout_offering: workout_offering 
      ).order('updated_at DESC').first
    else # only user is specified
      workout_scores.where(user: user).first
    end
  end


  #~ Class methods ............................................................

  # -------------------------------------------------------------
  def self.search(terms, user, course, searching_offerings)
    split_terms = terms.blank? ? '.' : terms.join('|')

    if user
      available_workouts = Workout.where(
        id: (Workout.visible_to_user(user) + user.managed_workouts)
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
      available_workouts = Workout.where(is_public: true)
    end

    return available_workouts.tagged_with(terms, any: true, wild: true, on: :tags) +
      available_workouts.tagged_with(terms, any: true, wild: true, on: :languages) +
      available_workouts.tagged_with(terms, any: true, wild: true, on: :styles) +
      available_workouts.where('name regexp (?)', split_terms).uniq
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
