# == Schema Information
#
# Table name: workouts
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  scrambled  :boolean          default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :workout do
  end
end
