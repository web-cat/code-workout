# == Schema Information
#
# Table name: coding_questions
#
#  id           :integer          not null, primary key
#  created_at   :datetime
#  updated_at   :datetime
#  exercise_id  :integer
#  class_name   :string(255)
#  wrapper_code :text
#  test_script  :text
#  method_name  :string(255)
#  starter_code :text
#
# Indexes
#
#  index_coding_questions_on_exercise_id  (exercise_id)
#

class CodingQuestion < ActiveRecord::Base


  #~ Validations
  validates :wrapper_code, presence: true, allow_blank: false
  validates :test_script, presence: true, allow_blank: false

  #~ Relationships
  belongs_to :exercise
  has_many :test_cases

  #~ Acceptance
  accepts_nested_attributes_for :test_cases, allow_destroy: true
end
