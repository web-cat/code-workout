# == Schema Information
#
# Table name: multiple_choice_prompt_answers
#
#  id :integer          not null, primary key
#

# =============================================================================
# Represents one coding prompt answer in an exercise attempt.  In spirit,
# this is a subclass of PromptAnswer, and inherits all of the fields of
# PromptAnswer via acts_as (see the documentation on-line for the
# activerecord-acts_as gem).
#
class MultipleChoicePromptAnswer < ActiveRecord::Base

  #~ Relationships ............................................................

  acts_as :prompt_answer
  has_and_belongs_to_many :choices, inverse_of: :multiple_choice_prompt_answers


  #~ Validation ...............................................................

end
