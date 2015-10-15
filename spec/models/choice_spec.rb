# == Schema Information
#
# Table name: choices
#
#  id                        :integer          not null, primary key
#  multiple_choice_prompt_id :integer          not null
#  position                  :integer          not null
#  feedback                  :text
#  value                     :float(24)        not null
#  created_at                :datetime
#  updated_at                :datetime
#  answer                    :text             not null
#
# Indexes
#
#  index_choices_on_multiple_choice_prompt_id  (multiple_choice_prompt_id)
#

require 'spec_helper'

describe Choice do
  pending "add some examples to (or delete) #{__FILE__}"
end
