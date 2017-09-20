class AddCourseOfferingToExerciseCollection < ActiveRecord::Migration
  def change
    add_reference :exercise_collections, :course_offering, index: true, foreign_key: true
  end
end
