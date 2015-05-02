# == Schema Information
#
# Table name: choices
#
#  id                        :integer          not null, primary key
#  multiple_choice_prompt_id :integer          not null
#  answer                    :string(255)      not null
#  position                  :integer          not null
#  feedback                  :text
#  value                     :float            not null
#  created_at                :datetime
#  updated_at                :datetime
#
# Indexes
#
#  index_choices_on_multiple_choice_prompt_id  (multiple_choice_prompt_id)
#

require 'spec_helper'

describe Choice do
  pending "add some examples to (or delete) #{__FILE__}"
end
