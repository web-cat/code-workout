class AddOpeningDateToStudentExtensions < ActiveRecord::Migration
  def change
    add_column :student_extensions, :opening_date, :datetime
  end
end
