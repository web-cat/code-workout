class AddOpeningDateToStudentExtensions < ActiveRecord::Migration[5.1]
  def change
    add_column :student_extensions, :opening_date, :datetime
  end
end
