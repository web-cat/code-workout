# == Schema Information
#
# Table name: test_cases
#
#  id                :integer          not null, primary key
#  test_script       :string(255)
#  negative_feedback :text             not null
#  weight            :float            not null
#  description       :text
#  input             :string(255)      not null
#  expected_output   :string(255)      not null
#  created_at        :datetime
#  updated_at        :datetime
#  coding_prompt_id  :integer          not null
#
# Indexes
#
#  index_test_cases_on_coding_prompt_id  (coding_prompt_id)
#

class TestCase < ActiveRecord::Base

  #~ Relationships ............................................................

  belongs_to :coding_prompt, inverse_of: :test_cases
  has_many :test_case_results, inverse_of: :test_case, dependent: :destroy


  #~ Validation ...............................................................

  validates :input, presence: true
  validates :expected_output, presence: true
  validates :negative_feedback, presence: true
  validates :coding_prompt, presence: true
  validates :weight, presence: true, numericality: { greater_than: 0 }

end
