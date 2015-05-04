class AddCutoffDateToCourseOfferings < ActiveRecord::Migration
  def change
    add_column :course_offerings, :cutoff_date, :date
  end
end
