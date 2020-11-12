class AddLmsInstanceToCourseOffering < ActiveRecord::Migration[5.1]
  def change
    add_reference :course_offerings, :lms_instance, index: true
  end
end
