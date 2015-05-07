# == Schema Information
#
# Table name: coding_prompts
#
#  id           :integer          not null, primary key
#  created_at   :datetime
#  updated_at   :datetime
#  class_name   :string(255)
#  wrapper_code :text             not null
#  test_script  :text             not null
#  method_name  :string(255)
#  starter_code :text
#

require 'rails_helper'

RSpec.describe CodingQuestion, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
