# == Schema Information
#
# Table name: exercise_workouts
#
#  id          :integer          not null, primary key
#  exercise_id :integer          not null
#  workout_id  :integer          not null
#  position    :integer          not null
#  points      :float(24)        default(1.0)
#  created_at  :datetime
#  updated_at  :datetime
#
# Indexes
#
#  exercise_workouts_exercise_id_fk  (exercise_id)
#  exercise_workouts_workout_id_fk   (workout_id)
#

require 'rails_helper'

RSpec.describe ExerciseWorkout, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
