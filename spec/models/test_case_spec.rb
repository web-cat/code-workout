# == Schema Information
#
# Table name: test_cases
#
#  id                 :integer          not null, primary key
#  test_script        :string(255)
#  negative_feedback  :text             not null
#  weight             :float            not null
#  description        :text
#  input              :string(255)      not null
#  expected_output    :string(255)      not null
#  created_at         :datetime
#  updated_at         :datetime
#  coding_question_id :integer          not null
#
# Indexes
#
#  index_test_cases_on_coding_question_id  (coding_question_id)
#

require 'rails_helper'

RSpec.describe TestCase, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
