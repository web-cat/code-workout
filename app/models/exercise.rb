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
  
  # -------------------------------------------------------------------
  # Method to correct the scoring of a MCQ whose correct choice is
  # invalidly specified. Need to specify the id of the exercise along
  # with the ids of the correct option and wrongly specified option.
  # The value of the old correct option can be specified if it is not 1
 
  def self.correct_mcq(ex_id, workout_id, correct_choice_id, wrong_choice_id, value = 1.0)
    if ex_id.nil? || !ex_id.is_a?(Integer)
      puts "Invalid exercise ID"
      return false
    end
    
    if correct_choice_id.nil? || !correct_choice_id.is_a?(Integer) || 
      wrong_choice_id.nil? || !wrong_choice_id.is_a?(Integer)
      puts "Invalid Choice ID"
      return false
    end
    
    exercise_version_id = Exercise.find(ex_id).current_version_id
    correct_choice = Choice.find(correct_choice_id) 
    wrong_choice = Choice.find(wrong_choice_id)
    
    if correct_choice.multiple_choice_prompt_id != wrong_choice.multiple_choice_prompt_id
      puts "Choices are not from the same question"
      return false
    end
    correct_choice.reset_value(value)
    wrong_choice.reset_value(0.0)
    
    workoutscore = WorkoutScore.find_by(exercise_id: ex_id, workout_id: workout_id)
    affected_attempts = Attempt.where(exercise_version_id: exercise_version_id, workout_score: workoutscore)
    
    affected_attempts.each do |attempt|
      delta = 0.0
      if correct_choice_id == attempt.prompt_answers[0].specific.choices[0].id && attempt.score <= 0.0
        delta = value
      elsif wrong_choice_id == attempt.prompt_answers[0].specific.choices[0].id && attempt.score > 0.0
        delta = -1.0 * value
      end
      puts attempt.id,"\n DELTA: \n", delta
      if workout_id && ExerciseWorkout.
        find_by(exercise_id: ex_id, workout_id: workout_id).andand.points
        multiplier = ExerciseWorkout.find_by(exercise_id: ex_id, workout_id: workout_id).points
        if attempt.active_score
          attempt.active_score.rescore(delta * multiplier)
        end
      else
        multiplier = 10.0
      end
      attempt.rescore(delta * multiplier)
    end
    return true
  end

  # --------------------------------------------------------------------
  # Method to correct the scoring of a Coding question where a test case
  # is faulty. Need to specify the id of the exercise along
  # with the id of the incorrect test case.
  # This method simply sets the weight of the faulty test case to zero
  # and re-computes the score, updating the attempt and workout score.
 
  def self.correct_test_case_scoring(ex_id, workout_id, test_case_id)
    if ex_id.nil? || !ex_id.is_a?(Integer)
      puts "Invalid exercise ID"
      return false
    end
    
    
    if test_case_id.nil? || !test_case_id.is_a?(Integer)
      puts "Invalid test case ID"
      return false
    end
    
    exercise_version = Exercise.find(ex_id).current_version
    faulty_test_case = TestCase.find(test_case_id)
    
    if exercise_version.prompts[0].actable_id != faulty_test_case.coding_prompt_id
      puts "Test case is not from the same exercise"
      return false
    end
    
    # Neutalizing the test case henceforth
    faulty_test_case.weight = 0.0
    faulty_test_case.save!
    
    workoutscore = WorkoutScore.find_by(exercise_id: ex_id, workout_id: workout_id)
    affected_attempts = Attempt.where(exercise_version: exercise_version, workout_score: workoutscore)
    
    affected_attempts.each do |attempt|
      delta = 0.0
      related_test_cases = exercise_version.prompts[0].specific.test_cases
      total = 0.0
      correct = 0.0
      # Re-calculating the score for this exercise based on recorded results
      related_test_cases.each do |test_case|
        if TestCaseResult.where(test_case: test_case, user: attempt.user).last.pass
          correct += 1.0 * test_case.weight
        end
        total += test_case.weight
      end
      
      old_score = attempt.score
      
      
      if workout_id && ExerciseWorkout.
        find_by(exercise_id: ex_id, workout_id: workout_id).andand.points
        multiplier = ExerciseWorkout.find_by(exercise_id: ex_id, workout_id: workout_id).points
        new_score = correct * multiplier / total
        delta = new_score - old_score
        
        if attempt.active_score
          attempt.active_score.rescore(delta)
        end
        binding.pry if attempt.id == 199
      else
        multiplier = 10.0
        new_score = correct * multiplier / total
        delta = new_score - old_score
      end
      puts attempt.id,"\n DELTA: \n", delta
      attempt.rescore(delta)
    end
    return true
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
