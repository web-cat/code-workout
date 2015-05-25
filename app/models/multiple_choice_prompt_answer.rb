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
  validates :answer, presence: true

  #~ Class method .............................................................
  def self.record_answer(exv,responses,att)
      mcq_answer = MultipleChoicePromptAnswer.new(attempt: att, prompt: exv.prompts.first)
      if exv.prompts.first.specific.allow_multiple
        mcq_answer.answer = responses.
          compact.delete_if { |x| x.empty? }
        mcq_answer.answer = mcq_answer.answer.join(',')
      else
        mcq_answer.answer = responses.first
      end
      return mcq_answer
  end
  
end
