class CreateCourseRoles < ActiveRecord::Migration[5.1]
  def change
    create_table :course_roles do |t|
      t.string :name, :unique => true, :null => false
      t.boolean :can_manage_course, :null => false, :default => false
      t.boolean :can_manage_assignments, :null => false, :default => false
      t.boolean :can_grade_submissions, :null => false, :default => false
      t.boolean :can_view_other_submissions, :null => false, :default => false 
      t.boolean :builtin, :null => false, :default => false
    end
  end
end
