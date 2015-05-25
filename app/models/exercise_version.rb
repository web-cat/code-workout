# == Schema Information
#
# Table name: exercise_versions
#
#  id          :integer          not null, primary key
#  stem_id     :integer
#  created_at  :datetime
#  updated_at  :datetime
#  exercise_id :integer          not null
#  version     :integer          not null
#  creator_id  :integer
#  irt_data_id :integer
#
# Indexes
#
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
    prompts.first.specific.question_type
  end


  # -------------------------------------------------------------
  def is_mcq?
    prompts.first.specific.is_mcq?
  end


  # -------------------------------------------------------------
  def is_coding?
    prompts.first.specific.is_coding?
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
      submit_time: Time.now,
      submit_num: num
      )
    args.merge!(attempt: attempt)
    prompts.each do |prompt|
      prompt.new_answer(args)
    end
    attempt
  end


  # -------------------------------------------------------------
  # FIXME: move to multiple_choice_prompt
  def serve_choice_array
    if self.prompts.first.specific.choices.nil?
      return ["No answers available"]
    else
      answers = Array.new
      raw = self.prompts.first.specific.choices.sort_by{ |a| a[:position] }
      raw.each do |c|
        answers.push(c)
      end
      if self..prompts.first.specific.is_scrambled
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

  # -------------------------------------------------------------
  # A method to return the maximum score possible for a 
  # a stand-alone mcq
  def max_mcq_score
    if self.exercise.is_mcq?
      sum  = 0.0
      self.prompts.first.specific.choices.each do |choice|
        sum += choice.value if choice.value > 0.0
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
  def experience_on(answered, attempt)
    total = score(answered)
    options = prompts.first.specific.choices.size

    if (options == 0 || attempt == 0)
      return 0
    elsif (total >= 100 && attempt == 1)
      return self.exercise.experience
    elsif (attempt >= options)
      return 0
    elsif (total >= 100)
      return self.exercise.experience - self.exercise.experience * (attempt - 1) / options
    else
      return self.exercise.experience / options / 4
    end
  end

end
