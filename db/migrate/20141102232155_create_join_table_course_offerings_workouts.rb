class CreateJoinTableCourseOfferingsWorkouts < ActiveRecord::Migration
  def change
    create_join_table :course_offerings, :workouts do |t|
      # t.index [:course_offering_id, :workout_id]
      # t.index [:workout_id, :course_offering_id]
    end
  end
end
