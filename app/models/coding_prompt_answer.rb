# == Schema Information
#
# Table name: coding_prompt_answers
#
#  id     :integer          not null, primary key
#  answer :text
#  error  :text
#

# =============================================================================
# Represents one coding prompt answer in an exercise attempt.  In spirit,
# this is a subclass of PromptAnswer, and inherits all of the fields of
# PromptAnswer via acts_as (see the documentation on-line for the
# activerecord-acts_as gem).
#
class CodingPromptAnswer < ActiveRecord::Base

  #~ Relationships ............................................................

  acts_as :prompt_answer
  has_many :test_case_results, #-> { order('test_case_id ASC') },
    inverse_of: :coding_prompt_answer, dependent: :destroy


  #~ Validation ...............................................................

  # Note: there is no validates :answer, presence: true here, intentionally.
  # There may be cases where a user attempts an exercise but does not
  # answer all prompts, and that would constitute an empty answer. We
  # want to allow that, so do not add validations preventing it.

end
