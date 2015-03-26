# == Schema Information
#
# Table name: test_case_results
#
#  id                 :integer          not null, primary key
#  test_case_id       :integer          not null
#  user_id            :integer          not null
#  execution_feedback :text
#  created_at         :datetime
#  updated_at         :datetime
#  pass               :boolean          not null
#
# Indexes
#
#  index_test_case_results_on_test_case_id  (test_case_id)
#  index_test_case_results_on_user_id       (user_id)
#

class TestCaseResult < ActiveRecord::Base

  #~ Relationships ............................................................

  belongs_to :user, inverse_of: :test_case_results
  belongs_to :test_case, inverse_of: :test_case_results


  #~ Validation ...............................................................

  validates :user, presence: true
  validates :test_case, presence: true
  validates :pass, presence: true

end
