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

require 'rails_helper'

RSpec.describe TestCaseResult, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
