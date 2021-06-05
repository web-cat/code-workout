class AddMarkToWorkoutOfferingScoreSummary < ActiveRecord::Migration
  def change
    add_column :workout_offering_score_summaries, :mark, :boolean
    add_column :workout_offering_score_summaries, :total_students, :int
  end
end
