class ExerciseWorkout < ActiveRecord::Base
  belongs_to :exercise
  belongs_to :workout
  
  #return the points for an exercise belonging to a particular workout
  def self.findExercisePoints(exid,wktid)
    wex=ExerciseWorkout.find_by(exercise_id: exid, workout_id: wktid)
    return wex.points
  end
end
