class CreateCourseExercises < ActiveRecord::Migration
  def change
    create_table :course_exercises do |t|
      t.integer :course_id
      t.integer :exercise_id

      t.timestamps
    end
  end
end
