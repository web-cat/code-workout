# == Schema Information
#
# Table name: exercise_versions
#
#  id                  :integer          not null, primary key
#  stem_id             :integer
#  created_at          :datetime
#  updated_at          :datetime
#  exercise_id         :integer          not null
#  version             :integer          not null
#  creator_id          :integer
#  irt_data_id         :integer
#  text_representation :text(16777215)
#
# Indexes
#
#  exercise_versions_creator_id_fk         (creator_id)
#  exercise_versions_irt_data_id_fk        (irt_data_id)
#  index_exercise_versions_on_exercise_id  (exercise_id)
#  index_exercise_versions_on_stem_id      (stem_id)
#

require "cgi"

# =============================================================================
# Represents one version of an exercise--a single snapshot in the exercise's
# entire edit history.
#
class ExerciseVersion < ActiveRecord::Base

  #~ Accessor
  attr_accessor :answer_code


  #~ Relationships ............................................................

  belongs_to  :creator, class_name: 'User'
  belongs_to  :stem, inverse_of: :exercise_versions
  belongs_to  :exercise, inverse_of: :exercise_versions,
    counter_cache: :versions
  acts_as_list scope: :exercise, column: 'version'
  has_many :courses, through: :exercise
  has_many :workouts, through:  :exercise
  has_many :prompts, -> { order('position ASC') },
    inverse_of: :exercise_version, dependent: :destroy
  accepts_nested_attributes_for :prompts, allow_destroy: true  
  has_many :attempts, dependent: :destroy
  has_and_belongs_to_many :resource_files
  belongs_to :creator, class_name: 'User'
  belongs_to :irt_data, dependent: :destroy


  #~ Hooks ....................................................................


  #~ Validation ...............................................................

  validates :exercise, presence: true


  #~ Public instance methods ..................................................

  # -------------------------------------------------------------
  def question_type
    prompts.first.andand.question_type
  end

  # -------------------------------------------------------------------
  # Method to correct the scoring of a MCQ whose correct choice is
  # invalidly specified. Need to specify the ids of the correct option 
  # and wrongly specified option.
  # The value of the old correct option can be specified if it is not 1
 
  def correct_mcq(correct_choice_id, wrong_choice_id = nil, value = 1.0)
    if correct_choice_id.nil? || !correct_choice_id.is_a?(Integer)
      puts "Invalid Choice ID"
      return false
    end
    
    exercise_version_id = self.id
    correct_choice = Choice.find(correct_choice_id)
    wrong_choice = nil    
    if wrong_choice_id.nil?
      all_choices = Choice.where(multiple_choice_prompt: correct_choice.multiple_choice_prompt)
      all_choices.each do |c|
        wrong_choice = c if c.value == 1.0 
      end
      binding.pry
    end 
    wrong_choice ||= wrong_choice_id ? Choice.find(wrong_choice_id) : nil 
    
    if correct_choice.multiple_choice_prompt_id != wrong_choice.multiple_choice_prompt_id
      puts "Choices are not from the same question"
      return false
    end
    correct_choice.reset_value(value)
    wrong_choice.reset_value(0.0) if wrong_choice
    
    attempts.each do |attempt|
      delta = 0.0
      if correct_choice_id == attempt.prompt_answers[0].specific.choices[0].id && attempt.score <= 0.0
        delta = value
      elsif wrong_choice && wrong_choice.id == attempt.prompt_answers[0].specific.choices[0].id && attempt.score > 0.0
        delta = -1.0 * value
      end
      binding.pry
      puts attempt.id,"\n DELTA: \n", delta
      if attempt.workout_score
        multiplier = ExerciseWorkout.find_by(exercise: exercise, workout: attempt.workout_score.workout).points
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
  # is faulty. Need to specify the id of the incorrect test case.
  # This method simply sets the weight of the faulty test case to zero
  # and re-computes the score, updating the attempt and workout score.
 
  def correct_test_case_scoring(test_case_id)
    if test_case_id.nil? || !test_case_id.is_a?(Integer)
      puts "Invalid test case ID"
      return false
    end
    
    faulty_test_case = TestCase.find(test_case_id)
    
    if faulty_test_case.coding_prompt.specific.exercise_version != self
      puts "Test case is not from the same exercise"
      return false
    end
    
    # Neutalizing the test case henceforth
    faulty_test_case.weight = 0.0
    faulty_test_case.save!
    
    attempts.each do |attempt|
      delta = 0.0
      related_test_cases = faulty_test_case.coding_prompt.specific.test_cases
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
      
      if attempt.workout_score
        multiplier = ExerciseWorkout.find_by(exercise: exercise, workout: attempt.workout_score.workout).points
        new_score = correct * multiplier / total
        delta = new_score - old_score
        
        if attempt.active_score
          attempt.active_score.rescore(delta)
        end
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
    exercise.is_mcq?
  end


  # -------------------------------------------------------------
  def is_coding?
    exercise.is_coding?
  end


  # -------------------------------------------------------------
  def new_attempt(args)
    num = 1
    user = args[:user]
    if user
      num = Attempt.where(user: user, exercise_version: self).count + 1
    end
    attempt = Attempt.new(
      user: user,
      exercise_version: self,
      submit_time: Time.zone.now,
      submit_num: num
      )
    if args[:workout_score]
      attempt.workout_score = args[:workout_score]
    end
    args.merge!(attempt: attempt)
    prompts.each do |prompt|
      prompt.new_answer(args)
    end
    attempt
  end


  # -------------------------------------------------------------
  # FIXME: move to multiple_choice_prompt
  def serve_choice_array(question_prompt)
    if question_prompt.specific.choices.nil?
      return ["No answers available"]
    else
      answers = Array.new
      raw = question_prompt.specific.choices.sort_by{ |a| a[:position] }
      raw.each do |c|
        answers.push(c)
      end
      if question_prompt.specific.is_scrambled
        scrambled = Array.new
        until answers.empty?
          rand = Random.rand(answers.length)
          scrambled.push(answers.delete_at(rand))
        end
        answers = scrambled
      end
      return answers
    end
  end

  # ----------------------------------------------------------------
  # A method to return the maximum score possible for a
  # a stand-alone mcq
  # TODO: broken :-/
  # FIXME: Considers all multi-prompt questions to be of equal value
  def max_mcq_score
    if self.exercise.is_mcq?
      sum  = 0.0
      self.prompts.each do |question_prompt|
        question_prompt.specific.choices.each do |choice|
          sum += choice.value if choice.value > 0.0
        end
      end
      puts "MAX MCQ SCORE",sum,"MAX MCQ SCORE"
      return sum
    end
  end

  # -------------------------------------------------------------
  # Needs to be split among prompts.
  # Also, why is this here, and not in the attempt class?
  def score(answered)
    score = 0
    answered.each do |a|
      score += a.value
    end
    # TODO: Decide whether safeguarding against negative scoring is worth it
    if (score < 0)
      score = 0
    end
    return score
  end


  # -------------------------------------------------------------
  # Grab all feedback for choices either selected when wrong
  #  or not selected when (at least partially) right
  # FIXME: Move to multiple choice prompt
  def collate_feedback(answered)
    total = score(answered)
    feed = Array.new
    all = self.choices.sort_by{ |a| a[:position] }
    all.each do |choice|
      found = answered.select { |x| x["id"] == choice.id }
      if ((choice.value > 0 && (found.nil? || found.empty?)) ||
          (choice.value <= 0 && (!found.nil? && !found.empty?)))
        feed.push(choice.feedback)
      end
    end
    # if 100% correct, or no other feedback provided, give general feedback
    if (feed.empty? || total >= 100 &&
      (!self.feedback.nil? && !self.feedback.empty?))
      feed.push(self.feedback)
    end
    return feed
  end


  # -------------------------------------------------------------
  # FIXME: split across prompts?
  def mcq_experience_on(answered, attempt_no)
    total = score(answered)
    options = prompts.first.specific.choices.size

    if (options == 0 || attempt_no == 0)
      return 0
    elsif (total >= 1.0 && attempt_no == 1)
      return self.exercise.experience
    else
      return self.exercise.experience * total / options / attempt_no
    end
  end

end
