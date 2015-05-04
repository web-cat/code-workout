# == Schema Information
#
# Table name: test_case_results
#
#  id                      :integer          not null, primary key
#  test_case_id            :integer          not null
#  user_id                 :integer          not null
#  execution_feedback      :text
#  created_at              :datetime
#  updated_at              :datetime
#  pass                    :boolean          not null
#  coding_prompt_answer_id :integer
#
# Indexes
#
#  index_test_case_results_on_coding_prompt_answer_id  (coding_prompt_answer_id)
#  index_test_case_results_on_test_case_id             (test_case_id)
#  index_test_case_results_on_user_id                  (user_id)
#

require 'rails_helper'

RSpec.describe TestCaseResult, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
