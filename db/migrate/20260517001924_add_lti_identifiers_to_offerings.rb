class AddLtiIdentifiersToOfferings < ActiveRecord::Migration[5.2]
  def change
    add_column :course_offerings, :lms_section_id, :string
    add_column :workout_offerings, :resource_link_id, :string

    add_index :course_offerings, [:lms_instance_id, :lti_context_id, :lms_section_id], unique: true, name: 'idx_course_offerings_on_lms_context_section'
    add_index :workout_offerings, [:lms_instance_id, :resource_link_id], unique: true, name: 'idx_workout_offerings_on_lms_and_resource_link'
  end
end
