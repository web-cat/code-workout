# == Schema Information
#
# Table name: exercises
#
#  id                     :integer          not null, primary key
#  experience             :integer          not null
#  is_public              :boolean          default(FALSE), not null
#  name                   :string(255)
#  question_type          :integer          not null
#  versions               :integer
#  created_at             :datetime
#  updated_at             :datetime
#  current_version_id     :integer
#  exercise_collection_id :integer
#  exercise_family_id     :integer
#  external_id            :string(255)
#  irt_data_id            :integer
#
# Indexes
#
#  exercises_irt_data_id_fk                   (irt_data_id)
#  index_exercises_on_exercise_collection_id  (exercise_collection_id)
#  index_exercises_on_exercise_family_id      (exercise_family_id)
#  index_exercises_on_external_id             (external_id) UNIQUE
#  index_exercises_on_is_public               (is_public)
#
# Foreign Keys
#
#  exercises_exercise_family_id_fk  (exercise_family_id => exercise_families.id)
#  exercises_irt_data_id_fk         (irt_data_id => irt_data.id)
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
class Exercise < ActiveRecord::Base

  #~ Relationships ............................................................

  acts_as_taggable_on :tags, :languages, :styles
  has_many :exercise_versions, -> { order('version DESC') },
    inverse_of: :exercise, dependent: :destroy
  has_many :attempts, through: :exercise_versions
  has_many :course_exercises, inverse_of: :exercise, dependent: :destroy
  has_many :courses, through: :course_exercises
  has_many :exercise_workouts, inverse_of: :exercise, dependent: :destroy
  has_many :workouts, through: :exercise_workouts
  belongs_to :exercise_family, inverse_of: :exercises
  has_many :exercise_owners, inverse_of: :exercise, dependent: :destroy
  has_many :owners, through: :exercise_owners
  belongs_to :current_version, class_name: 'ExerciseVersion'
  belongs_to :irt_data, dependent: :destroy
  belongs_to :exercise_collection

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

  TYPE_NAMES = {
    Q_MC     => 'Multiple Choice Question',
    Q_CODING => 'Coding Question',
    Q_BLANKS => 'Fill in the blanks'
  }

  LANGUAGE_EXTENSION = {
    'Ruby' => 'rb',
    'Java' => 'java',
    'Python' => 'py',
    'Shell' => 'sh',
    'C++' => 'cpp'
  }


  scope :visible_through_user, -> (u) { joins{exercise_owners.outer}.joins{exercise_collection.outer}.
    where{ (exercise_owners.owner == u) | (exercise_collection.user == u) } }

    attr_accessor :iframe_url # to get values define in iframe url function for SPLICE

  #~ Class methods ............................................................

  # -------------------------------------------------------------
  def self.search(terms, user = nil)
    # first, turn all ids of the form X4 to just the number
    ids = []
    terms = terms.map{ |t| Regexp.escape(t) }
    terms.each do |t|
      if t =~ /^[x]\d+$/i
        ids.append t[1..-1]
      end
    end
    r = terms.join("|")
    if r.blank?
      return nil
    end
    if user
      visible = Exercise.visible_to_user(user)
    else
      visible = Exercise.publicly_visible
    end
    
    result = visible.tagged_with(terms, any: true, wild: true, on: :tags)
      .union(visible.tagged_with(terms, any: true, wild: true, on: :languages))
      .union(visible.tagged_with(terms, any: true, wild: true, on: :styles)) 
      .union(visible.where('(name regexp (?)) or (exercises.id in (?))', r, ids))
      .distinct
    return result
  end


  # -------------------------------------------------------------
  # Get a list of Exercises that are visible to the specified user.
  #
  # It is the union of exercises that are publicly visible, created or owned by the user,
  # part of an exercise collection owned by the user or by a group the user is a
  # member of, and exercises that are visible through a course_offering.
  def self.visible_to_user(user)
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
      .union(publicly_visible)
      .union(visible_through_course_offering)
      .union(visible_through_user_group)
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
      .where(is_public: nil, exercise_collection:
        { license:
          { license_policy:
            { is_public: true } } }
      )

    public_exercise = Exercise.where(is_public: true)

    return public_exercise.union(public_license)
  end

  # the iframeurl, iframe-embedcode and ltilaunch is to display and export each exercises information for SPLICE
  def iframe_url
    base_url = "https://code-workout.cs.vt.edu" # to be dynamically fetched maybe from a config file
    "#{base_url}/gym/exercises/#{self.id}/practice"
  end
  
  def iframe_embed_code
    "<iframe src='#{self.iframe_url}' height='600' width='150%'></iframe>"
  end

  def lti_launch_url
    base_url = "https://code-workout.cs.vt.edu" # to be fetched dynamically 
    "#{base_url}/lti/launch/gym/exercises/#{self.id}/practice"
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
    self.attempts.where(user: u, workout_score: nil).order('updated_at DESC').first
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
    # If updating this instance method, remember to update the class method
    # Exercise.visible_to_user(u). This method exists so avoid creating a list
    # of visible exercises unnecessarily.
    self.is_publicly_available? ||
    self.owners.include?(u) ||
    u.is_a_member_of?(self.exercise_collection.andand.user_group) ||
    self.exercise_collection.andand.owned_by?(u)
  end

  def is_publicly_available?
    unless self.is_public.nil?
      self.is_public
    else
      self.is_public ||
        self.exercise_collection.andand.is_public?
    end
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
