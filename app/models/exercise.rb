# == Schema Information
#
# Table name: exercises
#
#  id                     :integer          not null, primary key
#  question_type          :integer          not null
#  current_version_id     :integer
#  created_at             :datetime
#  updated_at             :datetime
#  versions               :integer
#  exercise_family_id     :integer
#  name                   :string(255)
#  is_public              :boolean          default(FALSE), not null
#  experience             :integer          not null
#  irt_data_id            :integer
#  external_id            :string(255)
#  exercise_collection_id :integer
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
    'Shell' => 'sh'
  }


  scope :visible_through_user, -> (u) { joins{exercise_owners.outer}.joins{exercise_collection.outer}.
    where{ (exercise_owners.owner == u) | (exercise_collection.user == u) } }


  #~ Class methods ............................................................

  # -------------------------------------------------------------
  def self.search(terms, user = nil)
    # first, turn all ids of the form X4 to just the number
    ids = []
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
      result = visible.tagged_with(terms, any: true, wild: true, on: :tags) +
        visible.tagged_with(terms, any: true, wild: true, on: :languages) +
        visible.tagged_with(terms, any: true, wild: true, on: :styles) +
        visible.where('(name regexp (?)) or (exercises.id in (?))', r, ids)
      return result.uniq
    else
      visible = Exercise.publicly_visible
      result = visible.tagged_with(terms, any: true, wild: true, on: :tags) +
        visible.tagged_with(terms, any: true, wild: true, on: :languages) +
        visible.tagged_with(terms, any: true, wild: true, on: :styles) +
        visible.where('(name regexp (?)) or (exercises.id in (?))', r, ids)
      return result.uniq
    end
  end

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

    visible_through_course_offering = Exercise.joins(exercise_collection: [ course_offering: :course_enrollments ])
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

  # Get exercises that are publicly visible, either by the Exercise.is_public
  # property, or by the license assigned to the Exercise's collection.
  #
  # Also the list of exercises that can be seen/searched/practiced without being
  # signed in.
  def self.publicly_visible
    public_license = Exercise.joins(exercise_collection: [ license: :license_policy ])
      .where(is_public: nil, exercise_collection:
        { license:
          { license_policy:
            { is_public: true } } }
      )

    public_exercise = Exercise.where(is_public: true)

    return public_exercise.union(public_license)
  end

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

  def attempt_data
    exercise_versions.joins{ attempts.prompt_answers }
      .joins('LEFT JOIN workout_scores ON workout_scores.id = attempts.workout_score_id')
      .joins('LEFT JOIN workout_offerings ON workout_offerings.id = workout_scores.workout_offering_id')
      .joins('LEFT JOIN workouts ON workouts.id = workout_scores.workout_id')
      .joins('LEFT JOIN course_offerings ON course_offerings.id = workout_offerings.course_offering_id')
      .joins('LEFT JOIN terms ON terms.id = course_offerings.term_id')
      .joins('LEFT JOIN courses ON courses.id = course_offerings.course_id')
      .joins('LEFT JOIN coding_prompt_answers ON prompt_answers.actable_id = coding_prompt_answers.id')
      .select('attempts.user_id, exercise_versions.id as
        exercise_version_id, exercise_versions.version as version_no, coding_prompt_answers.id as answer_id,
        coding_prompt_answers.answer, coding_prompt_answers.error, attempts.id as attempt_id, attempts.submit_time,
        attempts.submit_num, attempts.score, workout_scores.score as workout_score, workouts.name as workout_name,
        courses.number as course_number, courses.name as course_name, terms.slug as term')
  end


  #~ Private instance methods .................................................
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

end
