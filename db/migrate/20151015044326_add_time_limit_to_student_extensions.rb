class AddTimeLimitToStudentExtensions < ActiveRecord::Migration[5.1]
  def change
    add_column :student_extensions, :time_limit, :int
  end
end
