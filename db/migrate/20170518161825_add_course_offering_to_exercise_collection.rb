class AddCourseOfferingToExerciseCollection < ActiveRecord::Migration[5.1]
  def change
    add_reference :exercise_collections, :course_offering, index: true, foreign_key: true
  end
end
