class AddCuratedToCourseExercises < ActiveRecord::Migration
  def change
    add_column :course_exercises, :curated, :boolean
    add_reference :course_exercises, :contributor, references: :users, index: true
    add_foreign_key :course_exercises, :users, column: :contributor_id
  end
end
