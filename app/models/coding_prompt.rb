# == Schema Information
#
# Table name: coding_prompts
#
#  id           :integer          not null, primary key
#  created_at   :datetime
#  updated_at   :datetime
#  class_name   :string(255)
#  wrapper_code :text             not null
#  test_script  :text             not null
#  method_name  :string(255)
#  starter_code :text
#

# =============================================================================
# Represents one coding prompt in an exercise.  In spirit,
# this is a subclass of Prompt, and inherits all of the fields of Prompt via
# acts_as (see the documentation on-line for the activerecord-acts_as
# gem).
#
class CodingPrompt < ActiveRecord::Base

  #~ Relationships ............................................................

  acts_as :prompt
  has_many :test_cases, inverse_of: :coding_prompt, dependent: :destroy


  #~ Validation ...............................................................

  validates :wrapper_code, presence: true
  validates :test_script, presence: true

  accepts_nested_attributes_for :test_cases, allow_destroy: true

end
