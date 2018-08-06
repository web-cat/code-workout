class AddTimeLimitToStudentExtensions < ActiveRecord::Migration
  def change
    add_column :student_extensions, :time_limit, :int
  end
end
