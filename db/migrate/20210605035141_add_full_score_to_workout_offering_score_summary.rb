class AddFullScoreToWorkoutOfferingScoreSummary < ActiveRecord::Migration
  def change
    add_column :workout_offering_score_summaries, :workout_full_score, :float
  end
end
