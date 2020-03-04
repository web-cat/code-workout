# == Schema Information
#
# Table name: choices
#
#  id                        :integer          not null, primary key
#  multiple_choice_prompt_id :integer          not null
#  position                  :integer          not null
#  feedback                  :text(65535)
#  value                     :float(24)        not null
#  created_at                :datetime
#  updated_at                :datetime
#  answer                    :text(65535)      not null
#
# Indexes
#
#  index_choices_on_multiple_choice_prompt_id  (multiple_choice_prompt_id)
#

FactoryBot.define do
  factory :choice do
    answer { 'A choice' }
    value { 0.0 }
  end
end
