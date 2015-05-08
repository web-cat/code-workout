class AddWorkoutOfferingToWorkoutScore < ActiveRecord::Migration
  def change
    change_table :workout_scores do |t|
      t.belongs_to :workout_offering
    end
    add_foreign_key :workout_scores, :workout_offerings
  end
end
