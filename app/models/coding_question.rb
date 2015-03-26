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

  #~ Relationships
  belongs_to :exercise, inverse_of: :coding_question
  has_many :test_cases, inverse_of: :coding_question, dependent: :destroy

  #~ Validations
  validates :wrapper_code, presence: true
  validates :test_script, presence: true

  #~ Acceptance
  accepts_nested_attributes_for :test_cases, allow_destroy: true
end
