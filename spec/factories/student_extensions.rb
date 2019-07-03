# == Schema Information
#
# Table name: student_extensions
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  workout_offering_id :integer
#  soft_deadline       :datetime
#  hard_deadline       :datetime
#  created_at          :datetime
#  updated_at          :datetime
#  time_limit          :integer
#  opening_date        :datetime
#
# Indexes
#
#  index_student_extensions_on_user_id              (user_id)
#  index_student_extensions_on_workout_offering_id  (workout_offering_id)
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :student_extension do
    soft_deadline { "2015-09-26 22:05:04" }
    hard_deadline { "2015-09-26 22:05:04" }
  end
end
