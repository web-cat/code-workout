# == Schema Information
#
# Table name: prompts
#
#  id                  :integer          not null, primary key
#  exercise_version_id :integer          not null
#  question            :text(65535)      not null
#  position            :integer          not null
#  feedback            :text(65535)
#  created_at          :datetime
#  updated_at          :datetime
#  actable_id          :integer
#  actable_type        :string(255)
#  irt_data_id         :integer
#
# Indexes
#
#  index_prompts_on_actable_id           (actable_id)
#  index_prompts_on_exercise_version_id  (exercise_version_id)
#  prompts_irt_data_id_fk                (irt_data_id)
#

# =============================================================================
# A base class for all concrete prompt classes.  This class should be
# considered abstract, and only exists to capture the common fields that
# all prompt subclasses share.  All subclasses of prompt inherit all of the
# fields of Prompt via acts_as (see the documentation on-line for the
# activerecord-acts_as gem).
#
# Any relationships that other entities have on Prompt are automatically
# polymorphic in nature, but should not use the rails "polymorphic" keyword.
# The polymorphic support is built into this class via "actable".
#
# A prompt represents the "parts" of the question in an exercise, which
# are presented in sequential order (never randomized, since they often
# follow a logical progression).
#
# Many simple questions contain only one prompt, which is the most common
# case.  However, a multi-part question (say, a question that has a), b), and
# c) subparts) is simply one exercise with multiple prompts (three, in
# this example).
#
# Prompts are ordered by "position", which starts at 1.
#
class Prompt < ActiveRecord::Base

  #~ Relationships ............................................................

  actable # MTI, with subclasses CodingPrompt and MultipleChoicePrompt

  # TODO: define Attempt model and relate to prompt for each student attempt
  belongs_to :exercise_version, inverse_of: :prompts
  acts_as_list scope: :exercise_version
  has_many :prompt_answers, inverse_of: :prompt, dependent: :destroy
  belongs_to :irt_data, dependent: :destroy
  # TODO: define Hint model and decide how a hint determines how it maps to
  # different types of incorrect attempts


  #~ Hooks ....................................................................


  #~ Validation ...............................................................

  validates :exercise_version, presence: true
  validates :question, presence: true

  # Note: position should not be validated, since it is auto-updated in
  # a hook after validation.


  #~ Class methods.............................................................

  #~ Instance methods .........................................................

  # TODO: methods for calculating scores, difficulty, and discrimination

  # -------------------------------------------------------------
  def question_type
    specific.question_type
  end


  # -------------------------------------------------------------
  def is_mcq?
    specific.is_mcq?
  end


  # -------------------------------------------------------------
  def is_coding?
    specific.is_coding?
  end


  # -------------------------------------------------------------
  def new_answer(args)
    answer = specific.new_answer(args)
    answer.attempt = args[:attempt]
    args[:attempt].prompt_answers << answer
    answer.prompt = self
    prompt_answers << answer
    answer
  end

end
