class AddLmsInstanceToLtiWorkout < ActiveRecord::Migration
  def change
    add_reference :lti_workouts, :lms_instance, index: true, foreign_key: true
  end
end
