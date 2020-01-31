# == Schema Information
#
# Table name: choices
#
#  id                        :integer          not null, primary key
#  multiple_choice_prompt_id :integer          not null
#  position                  :integer          not null
#  feedback                  :text(65535)
#  value                     :float(24)        not null
#  created_at                :datetime
#  updated_at                :datetime
#  answer                    :text(65535)      not null
#
# Indexes
#
#  index_choices_on_multiple_choice_prompt_id  (multiple_choice_prompt_id)
#

# =============================================================================
# Represents one choice in a multiple-choice prompt.
#
# The position field stores the choice's 1-based order (unless the choices get
# scrambled in presentation) among the list of choices.  New choices with
# the default value of 0 for position will be auto-moved to the end of the
# list (the position will be auto-updated), so only set the position on
# newly created choices if you want to force them to a different location
# (i.e., set position to 1 to make it first, pushing all others back).
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
  has_and_belongs_to_many :multiple_choice_prompt_answers, inverse_of: :choices


  #~ Hooks ....................................................................

  #~ Validation ...............................................................

  validates :multiple_choice_prompt, presence: true
  validates :answer, presence: true
  validates :value, presence: true,
    numericality: { greater_than_or_equal_to: 0 }

  # Note: position should not be validated, since it is auto-updated in
  # a hook after validation.


  #~ Private instance methods .................................................
  # ---------------------------------------------------------------------------
  # Reset the value of a choice to a particular value
  def reset_value(new_value)
    self.value = new_value
    self.save!
  end
end
