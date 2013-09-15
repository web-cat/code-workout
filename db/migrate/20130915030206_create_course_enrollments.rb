class CreateCourseEnrollments < ActiveRecord::Migration
  def change
    create_table :course_enrollments do |t|
      t.reference :user, index: true
      t.reference :course_offering, index: true
      t.reference :course_role, index: true
    end

    # disallow duplicate enrollments 
    add_index :course_enrollments, [:user_id, :course_offering_id], :unique => true
  end
end
