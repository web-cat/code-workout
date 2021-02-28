# == Schema Information
#
# Table name: student_extensions
#
#  id                  :integer          not null, primary key
#  hard_deadline       :datetime
#  opening_date        :datetime
#  soft_deadline       :datetime
#  time_limit          :integer
#  created_at          :datetime
#  updated_at          :datetime
#  user_id             :integer
#  workout_offering_id :integer
#
# Indexes
#
#  index_student_extensions_on_user_id              (user_id)
#  index_student_extensions_on_workout_offering_id  (workout_offering_id)
#
# Foreign Keys
#
#  student_extensions_user_id_fk              (user_id => users.id)
#  student_extensions_workout_offering_id_fk  (workout_offering_id => workout_offerings.id)
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :student_extension do
    soft_deadline { "2015-09-26 22:05:04" }
    hard_deadline { "2015-09-26 22:05:04" }
  end
end
