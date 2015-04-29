# == Schema Information
#
# Table name: coding_questions
#
#  id           :integer          not null, primary key
#  created_at   :datetime
#  updated_at   :datetime
#  exercise_id  :integer          not null
#  class_name   :string(255)
#  wrapper_code :text             not null
#  test_script  :text             not null
#  method_name  :string(255)
#  starter_code :text
#
# Indexes
#
#  index_coding_questions_on_exercise_id  (exercise_id)
#

class CodingQuestion < ActiveRecord::Base

  #~ Relationships ............................................................

  belongs_to :exercise_version, inverse_of: :coding_question
  has_many :test_cases, inverse_of: :coding_question, dependent: :destroy


  #~ Validation ...............................................................

  validates :wrapper_code, presence: true
  validates :test_script, presence: true
  validates :exercise_version, presence: true

  accepts_nested_attributes_for :test_cases, allow_destroy: true

end
