# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :question do
    title "Question title"
    body "This is the body of the question \n its just a sample."
    tags "loops; conditionals"
    exercise
    after(:create) do |q|
      create_pair(:response, question: q)
    end
  end
end
