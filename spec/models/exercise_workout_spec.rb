# == Schema Information
#
# Table name: exercise_workouts
#
#  id          :integer          not null, primary key
#  exercise_id :integer
#  workout_id  :integer
#  ordering    :integer
#  points      :float            default(1.0)
#  created_at  :datetime
#  updated_at  :datetime
#

require 'rails_helper'

RSpec.describe ExerciseWorkout, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
