class CreateCourseOfferings < ActiveRecord::Migration[5.1]
  def change
    create_table :course_offerings do |t|
      t.references :course, null: false, index: true
      t.references :term, null: false, index: true
      t.string :name, null: false
      t.string :label
      t.string :url
      t.boolean :self_enrollment_allowed

      t.timestamps
    end
  end
end
