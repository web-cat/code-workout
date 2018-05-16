class AddLmsCourseIdsToCourseOfferings < ActiveRecord::Migration
  def change
    add_column :course_offerings, :lti_context_id, :string
    add_column :course_offerings, :lms_course_id, :string
    add_column :course_offerings, :lms_section_id, :string
  end
end
