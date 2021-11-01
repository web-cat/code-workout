class AddScoreOptionsToWorkoutPolicy < ActiveRecord::Migration
  def change
    add_column :workout_policies, :hide_score_before_finish, :boolean
    add_column :workout_policies, :hide_score_in_review_before_close, :boolean
  end
end
