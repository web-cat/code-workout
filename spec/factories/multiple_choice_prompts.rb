# == Schema Information
#
# Table name: multiple_choice_prompts
#
#  id             :integer          not null, primary key
#  allow_multiple :boolean          default(FALSE), not null
#  is_scrambled   :boolean          default(TRUE), not null
#

FactoryBot.define do
  factory :multiple_choice_prompt do
    allow_multiple { false }
    is_scrambled { true }

    factory :mc_with_choices do
      after :create do |p|
        p.choices << FactoryBot.create(:choice, multiple_choice_prompt: p)
        p.choices << FactoryBot.create(:choice,
          answer: 'The right choice', value: 100, multiple_choice_prompt: p)
        p.choices << FactoryBot.create(:choice, multiple_choice_prompt: p)
      end
    end
  end
end
