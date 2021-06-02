class CreateExerciseScoreSummaries < ActiveRecord::Migration
  def change
    create_table :exercise_score_summaries do |t|
      t.float :start_students
      t.float :average_exercise_score
      t.float :full_score_students
      t.belongs_to :workout_offering, index: true
      t.belongs_to :exercise, index: true

      t.timestamps null: false
    end
  end
end
