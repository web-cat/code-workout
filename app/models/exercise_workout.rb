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

class ExerciseWorkout < ActiveRecord::Base
  belongs_to :exercise
  belongs_to :workout
  
  #return the points for an exercise belonging to a particular workout
  def self.findExercisePoints(exid,wktid)
    wex=ExerciseWorkout.find_by(exercise_id: exid, workout_id: wktid)
    return wex.points
  end
end
