# == Schema Information
#
# Table name: choices
#
#  id                        :integer          not null, primary key
#  multiple_choice_prompt_id :integer          not null
#  answer                    :text(255)        not null
#  position                  :integer          not null
#  feedback                  :text
#  value                     :float            not null
#  created_at                :datetime
#  updated_at                :datetime
#
# Indexes
#
#  index_choices_on_multiple_choice_prompt_id  (multiple_choice_prompt_id)
#

# =============================================================================
# Represents one choice in a multiple-choice prompt.
#
# The position field stores the choice's 0-based order (unless the choices get
# scrambled in presentation) among the list of choices.
#
# The value field stores a 0.0-1.0 indication of the percentage credit earned
# when the user selects this choice, where 0.0 indicates no value, and 1.0
# indicates full credit.  The sum of values over all choices for a single
# prompt should always be 1.0.  If a prompt allows the user to select
# multiple choices, normally each of the choices that must be selected would
# have a non-zero value indicating the partial credit awarded for that single
# choice.
#
class Choice < ActiveRecord::Base

  #~ Relationships ............................................................

  belongs_to :multiple_choice_prompt, inverse_of: :choices
  acts_as_list scope: :multiple_choice_prompt


  #~ Hooks ....................................................................

  #~ Validation ...............................................................

  validates :multiple_choice_prompt, presence: true
  validates :answer, presence: true
  validates :position, presence: true,
    numericality: { greater_than_or_equal_to: 0 }
  validates :value, presence: true,
    numericality: { greater_than_or_equal_to: 0 }


  #~ Private instance methods .................................................

end
