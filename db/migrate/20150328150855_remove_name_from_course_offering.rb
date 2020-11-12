class RemoveNameFromCourseOffering < ActiveRecord::Migration[5.1]
  def change
    remove_column :course_offerings, :name, :string
    change_column_null :course_offerings, :label, false
  end
end
