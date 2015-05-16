# == Schema Information
#
# Table name: prompt_answers
#
#  id           :integer          not null, primary key
#  attempt_id   :integer
#  prompt_id    :integer
#  actable_id   :integer
#  actable_type :string(255)
#
# Indexes
#
#  index_prompt_answers_on_actable_id                (actable_id)
#  index_prompt_answers_on_attempt_id                (attempt_id)
#  index_prompt_answers_on_attempt_id_and_prompt_id  (attempt_id,prompt_id) UNIQUE
#  index_prompt_answers_on_prompt_id                 (prompt_id)
#

# =============================================================================
# A base class for all concrete prompt answer classes.  This class should be
# considered abstract, and only exists to capture the common fields that
# all prompt answer subclasses share.  All subclasses of prompt answer inherit
# all of the fields of PromptAnswer via acts_as (see the documentation on-line
# for the activerecord-acts_as gem).
#
# Any relationships that other entities have on PromptAnswer are automatically
# polymorphic in nature, but should not use the rails "polymorphic" keyword.
# The polymorphic support is built into this class via "actable".
#
# A prompt answer represents a user's answer for one prompt in one attempt
# at an exercise.
#
class PromptAnswer < ActiveRecord::Base

  #~ Relationships ............................................................

  # MTI, with subclasses CodingPromptAnswer and MultipleChoicePromptAnswer
  actable

  belongs_to :attempt, inverse_of: :prompt_answers
  belongs_to :prompt, inverse_of: :prompt_answers


  #~ Hooks ....................................................................


  #~ Validation ...............................................................

  validates :attempt, presence: true
  validates :prompt, presence: true


  #~ Class methods.............................................................

  #~ Instance methods .........................................................

end
