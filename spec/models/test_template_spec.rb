# == Schema Information
#
# Table name: test_templates
#
#  id            :integer          not null, primary key
#  code_template :text(65535)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  test_case_id  :integer
#
# Indexes
#
#  index_test_templates_on_test_case_id  (test_case_id)
#
# Foreign Keys
#
#  fk_rails_...  (test_case_id => test_cases.id)
#

require 'rails_helper'

RSpec.describe TestTemplate, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
