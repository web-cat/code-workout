# == Schema Information
#
# Table name: choices
#
#  id                        :integer          not null, primary key
#  answer                    :text(65535)      not null
#  feedback                  :text(65535)
#  position                  :integer          not null
#  value                     :float(24)        not null
#  created_at                :datetime
#  updated_at                :datetime
#  multiple_choice_prompt_id :integer          not null
#
# Indexes
#
#  index_choices_on_multiple_choice_prompt_id  (multiple_choice_prompt_id)
#
# Foreign Keys
#
#  choices_multiple_choice_prompt_id_fk  (multiple_choice_prompt_id => multiple_choice_prompts.id)
#

FactoryBot.define do
  factory :choice do
    answer { 'A choice' }
    value { 0.0 }
  end
end
