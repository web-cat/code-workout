class RenameWorkoutsExercisesExercisesWorkouts < ActiveRecord::Migration[5.1]
  def change
  	rename_table :workouts_exercises, :exercises_workouts
  	#add_index "exercises_workouts", ["exercise_id"], name: "index_exercises_workouts_on_exercise_id"
    #add_index "exercises_workouts", ["workout_id"], name: "index_exercises_workouts_on_workout_id"

    #remove_index "workouts_exercises", ["exercise_id"], name: "index_workouts_exercises_on_exercise_id"
    #remove_index "workouts_exercises", ["workout_id"], name: "index_workouts_exercises_on_workout_id"
  end
end
