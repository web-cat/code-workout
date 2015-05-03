# == Schema Information
#
# Table name: multiple_choice_prompts
#
#  id             :integer          not null, primary key
#  allow_multiple :boolean          default(FALSE), not null
#  is_scrambled   :boolean          default(TRUE), not null
#



# =============================================================================
# Represents a multiple-choice prompt in a single ExerciseVersion.  In spirit,
# this is a subclass of Prompt, and inherits all of the fields of Prompt via
# acts_as (see the documentation on-line for the activerecord-acts_as
# gem).
#
# One multiple-choice prompt includes one or more choices, which are
# represented at different objects.
#
class MultipleChoicePrompt < ActiveRecord::Base

  #~ Relationships ............................................................

  acts_as :prompt
  has_many :choices, -> { order("position ASC") },
    inverse_of: :multiple_choice_prompt, dependent: :destroy


  #~ Validation ...............................................................

	validates :allow_multiple, presence: true
	validates :is_scrambled, presence: true


  #~ Class methods.............................................................


  #~ Instance methods .........................................................

end
