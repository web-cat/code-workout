class AddCompletedExercisesToTagUserScores < ActiveRecord::Migration[5.1]
  def change
  	add_column :tag_user_scores, :completed_exercises, :integer, :default => 0
  end
end
