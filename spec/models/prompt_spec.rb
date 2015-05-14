# == Schema Information
#
# Table name: prompts
#
#  id                  :integer          not null, primary key
#  exercise_version_id :integer          not null
#  question            :text             not null
#  position            :integer          not null
#  feedback            :text
#  created_at          :datetime
#  updated_at          :datetime
#  actable_id          :integer
#  actable_type        :string(255)
#  irt_data_id         :integer
#
# Indexes
#
#  index_prompts_on_actable_id           (actable_id)
#  index_prompts_on_exercise_version_id  (exercise_version_id)
#

require 'spec_helper'

describe Prompt do
  pending "add some examples to (or delete) #{__FILE__}"
end
