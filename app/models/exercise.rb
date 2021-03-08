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
#  index_exercises_on_current_version_id      (current_version_id)
#  index_exercises_on_exercise_collection_id  (exercise_collection_id)
#  index_exercises_on_exercise_family_id      (exercise_family_id)
#  index_exercises_on_external_id             (external_id) UNIQUE
#  index_exercises_on_is_public               (is_public)
#
# Foreign Keys
#
#  exercises_current_version_id_fk  (current_version_id => exercise_versions.id)
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
  # belongs_to :current_version, class_name: 'ExerciseVersion'
  has_many :current_versions, class_name: 'ExerciseVersion',foreign_key: "associated_id"
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
  



  def self.filter_by_language(ex_list,language_tag)
    if language_tag == "all" || ex_list.count == 0 ||language_tag == "All" || language_tag.nil?
      return ex_list
    else
      temp_array = ex_list.reject{|ex| (ex.current_versions.tagged_with([language_tag],:on => :coding_language).count == 0)}
      if temp_array.length == 0
        temp_array = ex_list.reject{|ex| (!ex.tag_list_on(:languages).include? language_tag)}
      end
      return Exercise.where(id: temp_array.map(&:id))
    end
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

  # Does the user own this exercise or its collection?
  # Through themselves or through a user group?
  def owned_by?(u)
    return self.owners.include?(u) ||
      self.exercise_collection.andand.owned_by?(u) ||
      u.is_a_member_of?(self.exercise_collection.andand.user_group)
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

    # -------------------------------------------------------------
    # split(create) multiple current_version and add relationship to exercise
    def split_by_language(language_list)
      self.current_versions.destroy_all
      if language_list.include? "language_list"
        language_list = language_list.scan(/language_list:(.*)\r/)[0][0].delete(" ").split(/[\|,\,]/)
      else
        language_list = language_list.delete(" ").split(/[\|,\,]/)
      end
      language_list.each do |lan|
        lan = lan.delete(" ")
        temp = self.current_versions.create(exercise_id: self.id)
        temp.coding_language_list.add(lan)
        temp.save
      end
      return language_list[0]
    end
  

    
    # -------------------------------------------------------------
    # List all kinds of language tags, so user can choose which one they want to query
    def self.get_all_language_tags()
      language_list = []
      Exercise.tags_on(:languages).each do |e|
        unless language_list.include? e.name
          language_list.push(e.name.capitalize)
        end       
      end
      return language_list
    end
  
  
    def cv_text_representation(text_representation)
      self.current_versions.each do |curr|
        curr.update(text_representation: text_representation)
      end
    end


    def self.get_correct_version_by_language(ex, lan)
      return ex.current_versions.tagged_with([lan], :match_all => true)[0]
      # ex.current_versions.map{|cv| 
      #   if cv.tag_list_on(:coding_language).include? lan
      #     return cv
      #   end
      # }
    end

  #~ Private instance methods .................................................
  private

  def set_defaults
    # Update current_version if necessary
    # TBD
    if !self.current_versions
      self.current_versions = self.exercise_versions.first
    end

    # self.question_type ||=
    #   (current_version && current_version.prompts.first) ?
    #     current_version.question_type : Q_MC
    # self.name ||= ''
    # self.experience ||= 10
    self.question_type ||=
    (current_versions.last && current_versions.last.prompts.first) ?
      current_versions.last.question_type : Q_MC
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
