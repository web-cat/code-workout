class WorkoutScoreExercise < ApplicationRecord

  #~ Relationships ............................................................

  belongs_to :workout_score, inverse_of: :workout_score_exercises
  belongs_to :exercise, inverse_of: :workout_score_exercises
  belongs_to :exercise_pool, inverse_of: :workout_score_exercises, optional: true

  acts_as_list scope: :workout_score


  #~ Validation ...............................................................

  validates :workout_score, presence: true
  validates :exercise, presence: true
  validates :points, numericality: { greater_than_or_equal_to: 0 }

end
