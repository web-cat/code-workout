class ChangeLtiIndexesOnWorkoutOfferingsToNonUnique < ActiveRecord::Migration[5.2]
  def up
    remove_index :workout_offerings, name: 'idx_workout_offerings_on_lms_and_lti_assignment'
    remove_index :workout_offerings, name: 'idx_workout_offerings_on_lms_and_resource_link'

    add_index :workout_offerings, [:lms_instance_id, :lti_assignment_id], name: 'idx_workout_offerings_on_lms_and_lti_assignment'
    add_index :workout_offerings, [:lms_instance_id, :resource_link_id], name: 'idx_workout_offerings_on_lms_and_resource_link'
  end

  def down
    remove_index :workout_offerings, name: 'idx_workout_offerings_on_lms_and_lti_assignment'
    remove_index :workout_offerings, name: 'idx_workout_offerings_on_lms_and_resource_link'

    add_index :workout_offerings, [:lms_instance_id, :lti_assignment_id], unique: true, name: 'idx_workout_offerings_on_lms_and_lti_assignment'
    add_index :workout_offerings, [:lms_instance_id, :resource_link_id], unique: true, name: 'idx_workout_offerings_on_lms_and_resource_link'
  end
end
