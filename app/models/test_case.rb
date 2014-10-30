# == Schema Information
#
# Table name: test_cases
#
#  id          :integer          not null, primary key
#  test_script :string(255)      not null
#  exercise_id :integer          not null
#  created_at  :datetime
#  updated_at  :datetime
#
# Indexes
#
#  index_test_cases_on_exercise_id  (exercise_id)
#

class TestCase < ActiveRecord::Base
  #~ Relationships ............................................................

  belongs_to :exercise

  #~ Hooks ....................................................................

  #~ Validation ...............................................................

  validates :testscript, presence: true, length: {minimum: 1}
  #validates :feedback
  
  #~ Private instance methods .................................................
end
