class AddLmsAssignmentUrlToWorkoutOfferings < ActiveRecord::Migration[5.1]
  def change
    add_column :workout_offerings, :lms_assignment_url, :string
  end
end
