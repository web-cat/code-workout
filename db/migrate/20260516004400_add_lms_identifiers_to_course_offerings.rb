class AddLmsIdentifiersToCourseOfferings < ActiveRecord::Migration[5.2]
  def change
    add_column :course_offerings, :canvas_course_id, :string
    add_column :course_offerings, :lti_context_id, :string
    
    add_index :course_offerings, :canvas_course_id
    add_index :course_offerings, :lti_context_id
  end
end
