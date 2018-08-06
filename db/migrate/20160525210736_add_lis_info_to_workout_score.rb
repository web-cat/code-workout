class AddLisInfoToWorkoutScore < ActiveRecord::Migration
  def change
    add_column :workout_scores, :lis_outcome_service_url, :string
    add_column :workout_scores, :lis_result_sourcedid, :string
  end
end
