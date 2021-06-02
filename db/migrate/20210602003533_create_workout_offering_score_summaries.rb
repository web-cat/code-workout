class CreateWorkoutOfferingScoreSummaries < ActiveRecord::Migration
  def change
    create_table :workout_offering_score_summaries do |t|
      t.float :start_students
      t.float :average_workout_score
      t.float :full_score_students
      t.belongs_to :workout_offering, index: true
      
      t.timestamps null: false
    end
  end
end
