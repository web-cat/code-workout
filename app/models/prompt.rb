# == Schema Information
#
# Table name: prompts
#
#  id                  :integer          not null, primary key
#  exercise_version_id :integer          not null
#  prompt              :text             not null
#  position            :integer          not null
#  attempt_count       :integer          not null
#  correct_count       :float            not null
#  feedback            :text
#  difficulty          :float            not null
#  discrimination      :float            not null
#  is_scrambled        :boolean
#  created_at          :datetime
#  updated_at          :datetime
#  actable_id          :integer
#  actable_type        :string(255)
#
# Indexes
#
#  index_prompts_on_actable_id           (actable_id) UNIQUE
#  index_prompts_on_exercise_version_id  (exercise_version_id)
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
class Prompt < ActiveRecord::Base

  #~ Relationships ............................................................

  actable # MTI, with subclasses CodingPrompt and MultipleChoicePrompt

  # TODO: define Attempt model and relate to prompt for each student attempt
  belongs_to :exercise_version, inverse_of: :prompts
  acts_as_list scope: :exercise_version

  # TODO: define Hint model and decide how a hint determines how it maps to
  # different types of incorrect attempts


  #~ Hooks ....................................................................


  #~ Validation ...............................................................

  validates :exercise_version, presence: true

  validates :prompt, presence: true
  validates :position, presence: true,
    numericality: { greater_than_or_equal_to: 0 }
  validates :attempt_count, presence: true,
    numericality: { greater_than_or_equal_to: 0 }
  validates :correct_count, presence: true,
    numericality: { greater_than_or_equal_to: 0 }
  #no validation for feedback
  validates :difficulty, presence: true, numericality: true
  validates :discrimination, presence: true, numericality: true

  # For actable
  validates :actable_id, presence: true
  validates :actable_type, presence: true


  #~ Class methods.............................................................

  #~ Instance methods .........................................................

  # TODO: methods for calculating scores, difficulty, and discrimination

end
