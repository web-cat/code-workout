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
