# == Schema Information
#
# Table name: prompts
#
#  id                  :integer          not null, primary key
#  exercise_version_id :integer          not null
#  prompt              :text             not null
#  position            :integer          not null
#  attempt_count       :integer          not null
#  correct_count       :float            not null
#  feedback            :text
#  difficulty          :float            not null
#  discrimination      :float            not null
#  is_scrambled        :boolean
#  created_at          :datetime
#  updated_at          :datetime
#  actable_id          :integer
#  actable_type        :string(255)
#
# Indexes
#
#  index_prompts_on_actable_id           (actable_id) UNIQUE
#  index_prompts_on_exercise_version_id  (exercise_version_id)
#

require 'spec_helper'

describe Prompt do
  pending "add some examples to (or delete) #{__FILE__}"
end
