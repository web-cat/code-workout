class AddCutoffDateToCourseOfferings < ActiveRecord::Migration[5.1]
  def change
    add_column :course_offerings, :cutoff_date, :date
  end
end
