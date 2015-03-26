# == Schema Information
#
# Table name: exercise_workouts
#
#  id          :integer          not null, primary key
#  exercise_id :integer          not null
#  workout_id  :integer          not null
#  order       :integer          not null
#  points      :float            default(1.0)
#  created_at  :datetime
#  updated_at  :datetime
#

class ExerciseWorkout < ActiveRecord::Base

  #~ Relationships ............................................................

  belongs_to :exercise, inverse_of: :exercise_workouts
  belongs_to :workout, inverse_of: :exercise_workouts


  #~ Validation ...............................................................

  validates :exercise, presence: true
  validates :workout, presence: true
  validates :ordering, presence: true,
    numericality: { greater_than_or_equal_to: 0 }


  #~ Class methods ............................................................

  # -------------------------------------------------------------
  #return the points for an exercise belonging to a particular workout
  def self.findExercisePoints(exid, wktid)
    wex = ExerciseWorkout.find_by(exercise_id: exid, workout_id: wktid)
    return wex.points
  end
end
