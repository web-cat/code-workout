# == Schema Information
#
# Table name: test_case_results
#
#  id                 :integer          not null, primary key
#  test_case_id       :integer
#  user_id            :integer
#  execution_feedback :text
#  created_at         :datetime
#  updated_at         :datetime
#  pass               :boolean
#

class TestCaseResult < ActiveRecord::Base

end
