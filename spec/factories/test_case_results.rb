# == Schema Information
#
# Table name: test_case_results
#
#  id                      :bigint           not null, primary key
#  execution_feedback      :text(65535)
#  feedback_line_no        :integer
#  pass                    :boolean          not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  coding_prompt_answer_id :bigint
#  test_case_id            :bigint           not null
#  user_id                 :bigint           not null
#
# Indexes
#
#  index_test_case_results_on_coding_prompt_answer_id  (coding_prompt_answer_id)
#  index_test_case_results_on_test_case_id             (test_case_id)
#  index_test_case_results_on_user_id                  (user_id)
#
# Foreign Keys
#
#  fk_rails_...                                  (test_case_id => test_cases.id)
#  fk_rails_...                                  (user_id => users.id)
#  test_case_results_coding_prompt_answer_id_fk  (coding_prompt_answer_id => coding_prompt_answers.id)
#  test_case_results_test_case_id_fk             (test_case_id => test_cases.id)
#  test_case_results_user_id_fk                  (user_id => users.id)
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :test_case_result do
    test_case_id { 1 }
    user_id { 1 }
    score { "" }
    execution_feedback { "MyText" }
  end
end
