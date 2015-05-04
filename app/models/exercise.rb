# == Schema Information
#
# Table name: exercises
#
#  id                 :integer          not null, primary key
#  question_type      :integer          not null
#  current_version_id :integer          not null
#  created_at         :datetime
#  updated_at         :datetime
#  versions           :integer          not null
#  exercise_family_id :integer
#  name               :string(255)
#  is_public          :boolean          default(FALSE), not null
#  experience         :integer          not null
#  irt_data_id        :integer
#
# Indexes
#
#  index_exercises_on_current_version_id  (current_version_id)
#  index_exercises_on_exercise_family_id  (exercise_family_id)
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

  has_many :exercise_versions, -> { order("position ASC") },
    inverse_of: :exercise, dependent: :destroy
  has_many :course_exercises, inverse_of: :exercise, dependent: :destroy
  has_many :courses, through: :course_exercises
  has_many :exercise_workouts, inverse_of: :exercise, dependent: :destroy
  has_many :workouts, through: :exercise_workouts
  belongs_to :exercise_family, inverse_of: :exercises
  has_many :exercise_owners, inverse_of: :exercise, dependent: :destroy
  has_many :owners, through: :exercise_owners
  belongs_to :current_version, class_name: 'ExerciseVersion'
  has_and_belongs_to_many :tags

  accepts_nested_attributes_for :tags, allow_destroy: true
  accepts_nested_attributes_for :exercise_versions, allow_destroy: true


  #~ Hooks ....................................................................

  before_validation :set_defaults


  #~ Validation ...............................................................

  validates :versions, presence: true, numericality: { greater_than: 0 }
  validates :question_type, presence: true, numericality: { greater_than: 0 }
  validates :experience, presence: true,
    numericality: { greater_than_or_equal_to: 0 }
  validates :count_attempts, presence: true,
    numericality: { greater_than_or_equal_to: 0 }
  validates :count_correct, presence: true,
    numericality: { greater_than_or_equal_to: 0 }
  validates :difficulty, presence: true,
    numericality: { greater_than_or_equal_to: 0 }
  validates :discrimination, presence: true, numericality: true

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


  #~ Public instance methods ..................................................

  def type_name
    TYPE_NAMES[self.question_type]
  end


  def is_mcq?
    self.question_type == Q_MC
  end


  def is_coding?
    self.question_type == Q_CODING
  end


  def is_fill_in_the_blanks?
    self.question_type == Q_BLANKS
  end


  #~ Private instance methods .................................................
  private

  def set_defaults
    self.question_type ||= Q_MC
  end


end
