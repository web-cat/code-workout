# == Schema Information
#
# Table name: test_cases
#
#  id                :integer          not null, primary key
#  negative_feedback :text
#  weight            :float(24)        not null
#  description       :text
#  created_at        :datetime
#  updated_at        :datetime
#  coding_prompt_id  :integer          not null
#  input             :text             not null
#  expected_output   :text             not null
#
# Indexes
#
#  index_test_cases_on_coding_prompt_id  (coding_prompt_id)
#

require 'rails_helper'

RSpec.describe TestCase, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
