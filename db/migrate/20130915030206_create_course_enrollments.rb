class CreateCourseEnrollments < ActiveRecord::Migration[5.1]
  def change
    create_table :course_enrollments do |t|
      t.references :user, index: true
      t.references :course_offering, index: true
      t.references :course_role, index: true
    end

    # disallow duplicate enrollments 
    add_index :course_enrollments, [:user_id, :course_offering_id], :unique => true
  end
end
