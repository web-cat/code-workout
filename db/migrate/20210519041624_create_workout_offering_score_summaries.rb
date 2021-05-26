class CreateWorkoutOfferingScoreSummaries < ActiveRecord::Migration
  def change
    create_table :workout_offering_score_summaries do |t|
      t.integer :start_students
      t.integer :all_students
      t.float :total_workout_score
      t.integer :full_score_students
      t.references :workout_offering, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
