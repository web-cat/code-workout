class AddStartToExerciseScoreSummary < ActiveRecord::Migration
  def change
    add_column :exercise_score_summaries, :start_students_int, :int
  end
end
