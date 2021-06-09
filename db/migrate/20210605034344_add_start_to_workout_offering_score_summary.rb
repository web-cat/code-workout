class AddStartToWorkoutOfferingScoreSummary < ActiveRecord::Migration
  def change
    add_column :workout_offering_score_summaries, :start_students_int, :int
  end
end
