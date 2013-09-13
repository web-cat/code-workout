class CreateCourseOfferings < ActiveRecord::Migration
  def change
    create_table :course_offerings do |t|
      t.integer :course_id, null: false
      t.integer :term_id, null: false
      t.string :name, null: false
      t.string :label
      t.string :url
      t.boolean :self_enrollment_allowed

      t.timestamps
    end
  end
end
