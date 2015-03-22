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

require 'rails_helper'

RSpec.describe CodingQuestion, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
