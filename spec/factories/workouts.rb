# == Schema Information
#
# Table name: workouts
#
#  id                :integer          not null, primary key
#  name              :string(255)      not null
#  scrambled         :boolean          default(FALSE)
#  created_at        :datetime
#  updated_at        :datetime
#  description       :text
#  points_multiplier :integer
#  creator_id        :integer
#  external_id       :string(255)
#
# Indexes
#
#  index_workouts_on_external_id  (external_id) UNIQUE
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :workout do
    name 'Workout from Factory'
    scrambled true
    description 'Created by Factory Girl for testing.'

    factory :workout_with_exercise do
      after :create do |w|
        FactoryGirl.create :exercise_workout,
          workout_id: w.id,
          exercise: FactoryGirl.create(:coding_exercise)
      end
    end
  end
end
