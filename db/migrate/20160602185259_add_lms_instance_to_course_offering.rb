class AddLmsInstanceToCourseOffering < ActiveRecord::Migration
  def change
    add_reference :course_offerings, :lms_instance, index: true
  end
end
