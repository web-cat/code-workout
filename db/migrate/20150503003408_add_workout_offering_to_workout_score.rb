class AddWorkoutOfferingToWorkoutScore < ActiveRecord::Migration[5.1]
  def change
    change_table :workout_scores do |t|
      t.belongs_to :workout_offering
    end
    add_foreign_key :workout_scores, :workout_offerings
  end
end
