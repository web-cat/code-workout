# == Schema Information
#
# Table name: exercises
#
#  id                     :bigint           not null, primary key
#  experience             :integer          not null
#  is_public              :boolean          default(FALSE), not null
#  name                   :string(255)
#  question_type          :integer          not null
#  versions               :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  current_version_id     :bigint
#  exercise_collection_id :bigint
#  exercise_family_id     :bigint
#  external_id            :string(255)
#  irt_data_id            :bigint
#
# Indexes
#
#  index_exercises_on_current_version_id      (current_version_id)
#  index_exercises_on_exercise_collection_id  (exercise_collection_id)
#  index_exercises_on_exercise_family_id      (exercise_family_id)
#  index_exercises_on_external_id             (external_id) UNIQUE
#  index_exercises_on_irt_data_id             (irt_data_id)
#  index_exercises_on_is_public               (is_public)
#
# Foreign Keys
#
#  exercises_current_version_id_fk  (current_version_id => exercise_versions.id)
#  exercises_exercise_family_id_fk  (exercise_family_id => exercise_families.id)
#  exercises_irt_data_id_fk         (irt_data_id => irt_data.id)
#  fk_rails_...                     (current_version_id => exercise_versions.id)
#  fk_rails_...                     (exercise_collection_id => exercise_collections.id)
#  fk_rails_...                     (exercise_family_id => exercise_families.id)
#  fk_rails_...                     (irt_data_id => irt_data.id)
#

# =============================================================================
# Represents a single exercise (question) that a student (or any user) can
# answer.  An exercise may include introductory text (a stem), and one
# or more prompts.  The prompts represent the "parts" of the question, which
# are presented in sequential order (never randomized, since they often
# follow a logical progression).
#
# Many simple questions contain only one prompt, which is the most common
# case.  However, a multi-part question (say, a question that has a), b), and
# c) subparts) is simply one exercise with multiple prompts (three, in
# this example).
#
# As exercises are edited over time, the edit history is maintained as
# a series of ExerciseVersion objects.  When a user answers an exercise,
# their attempt is associated with the specific ExerciseVersion that was
# in effect when they gave their answer.  New users seeing an exercise
# for the first time always see the newest version.
#
class Exercise < ApplicationRecord

  #~ Relationships ............................................................

  acts_as_taggable_on :tags, :languages, :styles
  has_many :exercise_versions, -> { order('version DESC') },
    inverse_of: :exercise, dependent: :destroy
  has_many :attempts, through: :exercise_versions
  has_many :course_exercises, inverse_of: :exercise, dependent: :destroy
  has_many :courses, through: :course_exercises
  has_many :exercise_workouts, inverse_of: :exercise, dependent: :destroy
  has_many :workouts, through: :exercise_workouts
  belongs_to :exercise_family, inverse_of: :exercises, optional: true
  has_many :exercise_owners, inverse_of: :exercise, dependent: :destroy
  has_many :owners, through: :exercise_owners
  belongs_to :current_version, class_name: 'ExerciseVersion', optional: true
  belongs_to :irt_data, dependent: :destroy, optional: true
  belongs_to :exercise_collection, optional: true

  accepts_nested_attributes_for :exercise_versions, allow_destroy: true

  #~ Hooks ....................................................................

  before_validation :set_defaults


  #~ Validation ...............................................................
  validates :name, presence: :true
  validates :question_type, presence: true, numericality: { greater_than: 0 }
  validates :experience, presence: true,
    numericality: { greater_than_or_equal_to: 0 }

  # This one might be needed, but might break the create path for
  # exercises, so I'm leaving it out for now:
  # validates :current_version, presence: true

  #~ Pagination ...............................................................
  max_paginates_per 40

  Q_MC     = 1
  Q_CODING = 2
  Q_BLANKS = 3
  Q_PARSONS = 4

  TYPE_NAMES = {
    Q_MC     => 'Multiple Choice Question',
    Q_CODING => 'Coding Question',
    Q_BLANKS => 'Fill in the blanks',
    Q_PARSONS => 'Parsons Problem'
  }

  LANGUAGE_EXTENSION = {
    'Ruby' => 'rb',
    'Java' => 'java',
    'Python' => 'py',
    'Shell' => 'sh',
    'C++' => 'cpp'
  }

  # NOTE: visible_through_user is defined as a class method below (line ~142)
  # using standard ActiveRecord syntax (left_outer_joins + where).


    #~ Class methods ............................................................

  MAX_SEARCH_RESULTS = 50

  # -------------------------------------------------------------
  def self.search(terms, user = nil)
    return Exercise.none if terms.blank?

    # Extract any numeric IDs (e.g., X123, x123, #123, 123)
    ids = []
    search_words = []
    terms.each do |t|
      cleaned = t.to_s.strip
      if cleaned =~ /^(?:x|#)?(\d+)$/i
        ids << $1.to_i
      elsif cleaned.present?
        search_words << cleaned
      end
    end

    return Exercise.none if ids.empty? && search_words.empty?

    # 1. Fast Path: Pure ID Search
    if search_words.empty?
      candidate_ids = ids.uniq.first(MAX_SEARCH_RESULTS)
    else
      # 2. General / Keyword Search
      # 2a. Match Exercises by Name or ID
      matching_name_or_id = Exercise.all
      name_clauses = []
      name_params = []
      search_words.each do |word|
        name_clauses << 'exercises.name LIKE ?'
        name_params << "%#{word}%"
      end

      if name_clauses.any?
        matching_name_or_id = matching_name_or_id.where(name_clauses.join(' OR '), *name_params)
        if ids.any?
          matching_name_or_id = matching_name_or_id.or(Exercise.where(id: ids))
        end
      elsif ids.any?
        matching_name_or_id = Exercise.where(id: ids)
      else
        matching_name_or_id = Exercise.none
      end

      matching_ids = matching_name_or_id.limit(MAX_SEARCH_RESULTS * 2).pluck(:id)

      # 2b. Match Exercises by Tags
      matching_tag_ids = []
      if search_words.any?
        tag_clauses = []
        tag_params = []
        search_words.each do |word|
          tag_clauses << 'tags.name LIKE ?'
          tag_params << "%#{word}%"
        end
        matching_tag_ids = Exercise.joins(taggings: :tag)
          .where(tag_clauses.join(' OR '), *tag_params)
          .limit(MAX_SEARCH_RESULTS * 2)
          .pluck(:id)
      end

      # Combine IDs preserving ranking (ID matches first, then name matches, then tag matches)
      all_matching_ids = (ids + matching_ids + matching_tag_ids).uniq
      candidate_ids = all_matching_ids.first(MAX_SEARCH_RESULTS * 2)
    end

    return Exercise.none if candidate_ids.empty?

    # 3. In-Memory Visibility Filtering
    # Preload associations needed for visibility checks and rendering
    candidates = Exercise.where(id: candidate_ids)
                         .includes(
                           :exercise_owners,
                           { exercise_collection: [ :user_group, { license: :license_policy }, :course_offering ] }
                         )

    candidate_map = candidates.index_by(&:id)

    visible_ids = []
    is_admin = user.andand.global_role.andand.is_admin?

    candidate_ids.each do |id|
      exercise = candidate_map[id]
      next unless exercise

      if is_admin || exercise.visible_to?(user)
        visible_ids << id
        break if visible_ids.size >= MAX_SEARCH_RESULTS
      end
    end

    return Exercise.none if visible_ids.empty?

    # 4. Return an ActiveRecord::Relation with preloaded associations, preserving order
    result = Exercise.where(id: visible_ids)
                     .includes(
                       { current_version: :prompts },
                       :tags,
                       :languages,
                       :exercise_owners,
                       :exercise_collection
                     )

    begin
      result = result.order(Arel.sql("FIELD(exercises.id, #{visible_ids.join(',')})"))
    rescue => e
      result = result.order(:name)
    end

    result
  end


  # -------------------------------------------------------------
  def self.visible_through_user(user)
    return Exercise.left_outer_joins(:exercise_owners)
      .left_outer_joins(:exercise_collection)
      .where('exercise_owners.owner_id = ? or exercise_collections.user_id = ?',
        user.id, user.id)
  end


  # -------------------------------------------------------------
  # Get a list of Exercises that are visible to the specified user.
  #
  # It is the union of exercises that are publicly visible, created or owned by the user,
  # part of an exercise collection owned by the user or by a group the user is a
  # member of, and exercises that are visible through a course_offering.
  def self.visible_to_user(user)
    if user.andand.global_role.andand.is_admin?
      return Exercise.all
    end
    # If updating this method, remember to update the instance method
    # exercise.visible_to?(user).

    # Get exercises owned or created by the user
    visible_through_user = Exercise.visible_through_user(user)

    publicly_visible = Exercise.publicly_visible

    visible_through_course_offering = Exercise.joins(
      exercise_collection: [ course_offering: :course_enrollments ])
      .where(exercise_collection:
        { course_offering:
          { course_enrollments:
            { user: user } } }
      )

    visible_through_user_group = Exercise.visible_through_user_group(user)

    return visible_through_user
      .union(Exercise.publicly_visible)
      .union(visible_through_course_offering)
      .union(Exercise.visible_through_user_group(user))
  end


  # -------------------------------------------------------------
  # Get exercises that are publicly visible, either by the Exercise.is_public
  # property, or by the license assigned to the Exercise's collection.
  #
  # Also the list of exercises that can be seen/searched/practiced without being
  # signed in.
  def self.publicly_visible
    public_license = Exercise.joins(
      exercise_collection: [ license: :license_policy ])
      .where('exercises.is_public is null and license_policies.is_public = true')
      # .where(is_public: nil, exercise_collection:
      #   { license:
      #     { license_policy:
      #       { is_public: true } } }
      # )

    public_exercises = Exercise.where(is_public: true)

    return public_exercises.union(public_license)
  end


  # -------------------------------------------------------------
  def self.visible_through_user_group(user)
    Exercise.joins(exercise_collection: [ user_group: :memberships ])
      .where(exercise_collection:
        { user_group:
          { memberships:
            { user: user } } }
      )
  end


  # -------------------------------------------------------------
  # return the extension of a given language
  # FIXME: This doesn't belong in this class and should be moved elsewhere
  #
  def self.extension_of(lang)
    LANGUAGE_EXTENSION[lang]
  end


  #~ Public instance methods ..................................................

  # -------------------------------------------------------------
  def type_name
    TYPE_NAMES[self.question_type]
  end



  # -------------------------------------------------------------
  def is_mcq?
    self.question_type == Q_MC
  end


  # -------------------------------------------------------------
  def is_coding?
    self.question_type == Q_CODING
  end


  # -------------------------------------------------------------
  def is_fill_in_the_blanks?
    self.question_type == Q_BLANKS
  end

  # -------------------------------------------------------------
  def is_parsons?
    self.question_type == Q_PARSONS
  end


  # -------------------------------------------------------------
  # getter override for name
  def display_name
    temp = display_number
    if !name.blank?
      temp += ': ' + name
    end
    return temp
  end


  # -------------------------------------------------------------
  # getter override for name
  def display_number
    'X' + id.to_s
  end


  # -------------------------------------------------------------
  # Determine the programming language of the exercise from its language tag
  def language
    tag = self.languages.first
    return tag ? tag.name : nil
  end


  # -------------------------------------------------------------
  # return true if user has attempted this exercise version or not.
  def user_attempted?(u_id)
    self.attempts.where(user_id: u_id).any?
  end

  # Get the latest "pure gym" attempt on the exercise by the given user
  # If what one wants is a scoring attempt (without workouts, etc.), use
  # the `score_for` methods on workouts and workout_offerings.
  def latest_attempt_for(u)
    if attempts.loaded?
      attempts.select { |a| a.user_id == u.andand.id && a.workout_score_id.nil? }
        .sort_by { |a| a.updated_at || Time.at(0) }
        .last
    else
      self.attempts.where(user: u, workout_score: nil).order('updated_at DESC').first
    end
  end

  # Does the user have privileged access to this exercise, either
  # by owning the exercise or having access to its
  # exercise_collection?
  def can_be_assigned_by?(u)
    return self.owned_by?(u) ||
      self.exercise_collection.andand.owned_by?(u) ||
      u.is_a_member_of?(self.exercise_collection.andand.user_group)
  end

  # Is the user one of this exercise's owners
  def owned_by?(u)
    return self.owners.include?(u)
  end

  # Make the user an exercise owner if they aren't already
  def add_owner!(u)
    unless self.owned_by?(u)
      ExerciseOwner.create(owner: u, exercise: self)
    end
  end

  # -------------------------------------------------------------
  def visible_to?(u)
    return true if u.andand.global_role.andand.is_admin?
    return self.is_publicly_available? if u.nil?

    self.is_publicly_available? ||
    self.exercise_owners.any? { |eo| eo.owner_id == u.id } ||
    self.owners.include?(u) ||
    u.is_a_member_of?(self.exercise_collection.andand.user_group) ||
    self.exercise_collection.andand.owned_by?(u) ||
    (self.exercise_collection.andand.course_offering.andand.is_enrolled?(u))
  end

  def is_publicly_available?
    unless self.is_public.nil?
      self.is_public
    else
      self.is_public ||
        self.exercise_collection.andand.is_public?
    end
  end

  def self.generate_slc_catalog(filename, base_url="https://codeworkout.cs.vt.edu")
    exercises = Exercise.publicly_visible

    catalog = exercises.map do |exercise|
      description = case exercise.question_type
                    when Q_MC
                      "Multiple-choice question"
                    when Q_CODING
                      "Coding question"
                    when Q_BLANKS
                      "Fill in the blanks question"
                    else
                      exercise.type_name
                    end

      item = {
        catalog_type: "SLCItem",
        persistentID: exercise.external_id.to_s,
        platform_name: "CodeWorkout",
        iframe_url: base_url +
          Rails.application.routes.url_helpers.exercise_practice_path(exercise) +
          "?lti_launch=true",
        title: exercise.name.to_s,
        description: description,
        author: exercise.owners.empty? ? [exercise.current_version&.creator&.display_name_with_email].compact : exercise.owners.map(&:display_name_with_email),
        features: exercise.question_type == Q_CODING ? ["Free Coding Problem"] : ["Question"],
        institution: ["Virginia Tech"],
        keywords: exercise.tags.map(&:name),
        programming_language: [exercise.language].compact,
        natural_language: ["English"]
      }

      license = exercise.exercise_collection.andand.license.andand.name
      item[:license] = license if license

      item
    end

    File.write(filename, JSON.pretty_generate(catalog))
  end

  def self.progsnap2_attempt_csv(exercise_id, course_id=nil, term_id=nil)
    denormalized = Exercise.denormalized_attempt_data(exercise_id, course_id, term_id)
    main_events = Exercise.progsnap2_main_events_csv(denormalized)
    code_states = Exercise.progsnap2_code_states_csv(denormalized)
    return main_events, code_states
  end

  def self.denormalized_attempt_csv(exercise_id)
    denormalized_data = Exercise.denormalized_attempt_data(exercise_id)
    exercise_attributes = %w{ exercise_id exercise_name }
    attempt_attributes = %w{
      user_id
      exercise_id
      exercise_version_id
      version_no
      answer_id
      answer
      error
      attempt_id
      submit_time
      submit_num
      score
      active_score_id
      workout_score_id
      workout_score
      workout_offering_id
      workout_id
      workout_name
      course_offering_id
      course_number
      course_name
      term }

    data = CSV.generate(headers: true) do |csv|
      csv << (exercise_attributes + attempt_attributes)
      denormalized_data.each do |submission|
        csv << ([ self.id, self.name ] +
          attempt_attributes.map { |a| submission.attributes[a] })
      end
    end
    return data
  end

  # Return denormalized attempt data for this exercise.
  # All relationship fields are in the same table, so null values
  # are possible for workout_id, workout_offering_id, course_id,
  # course_offering_id, etc.
  def self.denormalized_attempt_data(exercise_id=nil, course_id=nil, term_id=nil)

    unless exercise_id || (course_id && term_id)
      raise ArgumentError, 'Please specify one or more exercise ids, OR ' \
        'a course id and term id.'
    end

    course_filter = course_id ?
      "AND courses.id = #{course_id}" :
      ""
    term_filter = term_id ?
      "AND terms.id = #{term_id}" :
      ""

    if exercise_id
      result = Exercise.where(:id, exercise_id)
        .joins(exercise_versions: { attempts: :prompt_answers })
    else
      result = Exercise.joins(exercise_versions: { attempts: :prompt_answers })
    end
    result = result
      .joins('LEFT JOIN workout_scores ON
        workout_scores.id = attempts.workout_score_id')
      .joins('LEFT JOIN workout_offerings ON
        workout_offerings.id = workout_scores.workout_offering_id')
      .joins('LEFT JOIN workouts ON workouts.id = workout_scores.workout_id')
      .joins('LEFT JOIN course_offerings ON
        course_offerings.id = workout_offerings.course_offering_id')
      .joins('LEFT JOIN terms ON terms.id = course_offerings.term_id')
      .joins('LEFT JOIN courses ON courses.id = course_offerings.course_id')
      .joins('LEFT JOIN coding_prompt_answers ON
        prompt_answers.actable_id = coding_prompt_answers.id')

      if course_id
        result = result.where('courses.id = ?', course_id)
      end

      if term_id
        result = result.where('terms.id = ?', term_id)
      end

      result = result
        .select('attempts.user_id,
        exercises.id as exercise_id,
        exercise_versions.id as exercise_version_id,
        exercise_versions.version as version_no,
        coding_prompt_answers.id as answer_id,
        coding_prompt_answers.answer,
        coding_prompt_answers.error,
        attempts.id as attempt_id,
        attempts.submit_time,
        attempts.submit_num,
        attempts.score,
        attempts.active_score_id,
        workout_scores.id as workout_score_id,
        workout_scores.score as workout_score,
        workout_offerings.id as workout_offering_id,
        workouts.id as workout_id,
        workouts.name as workout_name,
        course_offerings.id as course_offering_id,
        courses.number as course_number,
        courses.name as course_name,
        terms.slug as term')
    # if workout_id
    #   result = result.where("workouts.id = #{workout_id}")
    # end

    return result
  end

  #~ Private methods .................................................
  private

  def set_defaults
    # Update current_version if necessary
    if !self.current_version
      self.current_version = self.exercise_versions.first
    end

    self.question_type ||=
      (current_version && current_version.prompts.first) ?
        current_version.question_type : Q_MC
    self.name ||= ''
    self.experience ||= 10
  end

  def self.progsnap2_main_events_csv(denormalized_data)
    # MainTable
    main_attributes = %w{
      SubjectID
      ToolInstances
      ServerTimestamp
      ServerTimezone
      CourseID
      CourseSectionID
      TermID
      AssignmentID
      ProblemID
      X-WorkoutOfferingID
      X-ExerciseID
      Attempt
      CodeStateID
      IsEventOrderingConsistent
      EventType
      Score
      Compile.Result
      CompileMessageType
      CompileMessageData
      EventID
      Order
      ParentEventID
    }

    data = CSV.generate(headers: true) do |csv|
      event_id = 0
      csv << main_attributes
      denormalized_data.each do |submission|
        attrs = submission.attributes
        user_id = attrs['user_id'] || 'UNKNOWN'
        tool_instances = 'Java 8; CodeWorkout'
        event_ordering_consistent = 'True'

        common_fields = [
          user_id,
          tool_instances,
          attrs['submit_time'].strftime("%Y-%m-%dT%H:%M:%S"),
          attrs['submit_time'].formatted_offset(false), # +0000
          attrs['course_number'],
          attrs['course_offering_id'],
          attrs['term'],
          attrs['workout_id'],
          attrs['exercise_id'],
          attrs['workout_offering_id'],
          attrs['exercise_version_id'],
          attrs['submit_num'],
          attrs['answer_id'],
          event_ordering_consistent,
        ]

        # Run.Program event
        run_program_event = common_fields + [
          'Run.Program',
          attrs['score'],
          nil, # Compile.Result
          nil, # CompileMessageType
          nil, # CompileMessageData
          event_id,
          event_id, # Order
          nil # ParentEventID
        ]

        csv << run_program_event

        parent_event_id = event_id
        event_id = event_id + 1

        # Compile event
        compile_event = common_fields + [
          'Compile',
          nil, # no score
          attrs['error'].nil? ? 'Success' : 'Error',
          nil, # CompileMessageType
          nil, # CompileMessageData
          event_id,
          event_id, # Order
          parent_event_id
        ]

        parent_event_id = event_id
        event_id = event_id + 1

        csv << compile_event

        # Compile.Error events
        if attrs['error']
          errors = attrs['error'].split(/(?=line \d+:)/)
          errors.each do |e|
            error_event = common_fields + [
              'Compile.Error',
              nil, # no score
              nil, # Compile.Result
              'SyntaxError',
              e,
              event_id,
              event_id, # Order
              parent_event_id
            ]

            event_id = event_id + 1
            csv << error_event
          end
        end
      end
    end

    return data
  end

  def self.progsnap2_code_states_csv(denormalized_data)
    code_state_attributes = %w{
      CodeStateID
      Code
    }

    data = CSV.generate(headers: true) do |csv|
      csv << code_state_attributes
      denormalized_data.each do |submission|
        csv << [
          submission.attributes['answer_id'],
          submission.attributes['answer']
        ]
      end
    end

    return data
  end
end
