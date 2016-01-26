# == Schema Information
#
# Table name: exercises
#
#  id                 :integer          not null, primary key
#  question_type      :integer          not null
#  current_version_id :integer
#  created_at         :datetime
#  updated_at         :datetime
#  versions           :integer
#  exercise_family_id :integer
#  name               :string(255)
#  is_public          :boolean          default(FALSE), not null
#  experience         :integer          not null
#  irt_data_id        :integer
#  external_id        :string(255)
#
# Indexes
#
#  index_exercises_on_current_version_id  (current_version_id)
#  index_exercises_on_exercise_family_id  (exercise_family_id)
#  index_exercises_on_external_id         (external_id) UNIQUE
#  index_exercises_on_is_public           (is_public)
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

  accepts_nested_attributes_for :exercise_versions, allow_destroy: true


  #~ Hooks ....................................................................

  before_validation :set_defaults


  #~ Validation ...............................................................

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


  scope :visible_to_user, -> (u) { joins{exercise_owners.outer}.
    where{ (is_public == true) | (exercise_owners.owner == u) } }


  #~ Class methods ............................................................

  # -------------------------------------------------------------
  def self.search(terms, user)
    if user
      return Exercise.visible_to_user(user).
        tagged_with(terms, wild: true, on: :tags) +
        Exercise.visible_to_user(user).
        tagged_with(terms, wild: true, on: :languages) +
        Exercise.visible_to_user(user).
        tagged_with(terms, wild: true, on: :styles)
    else
      return Exercise.where(is_public: true).
        tagged_with(terms, wild: true, on: :tags) +
        Exercise.where(is_public: true).
        tagged_with(terms, wild: true, on: :languages) +
        Exercise.where(is_public: true).
        tagged_with(terms, wild: true, on: :styles)
    end
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
    if not name.nil?
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
    self.is_public || self.owners.include?(u)
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
    self.is_public ||= true
    self.experience ||= 10
  end

end
