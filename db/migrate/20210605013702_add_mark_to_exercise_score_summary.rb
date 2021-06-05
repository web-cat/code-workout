class AddMarkToExerciseScoreSummary < ActiveRecord::Migration
  def change
    add_column :exercise_score_summaries, :mark, :boolean
    add_column :exercise_score_summaries, :total_students, :int
  end
end
