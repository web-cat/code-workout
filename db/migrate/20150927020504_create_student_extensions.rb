class CreateStudentExtensions < ActiveRecord::Migration
  def change
    create_table :student_extensions do |t|
      t.belongs_to :user, index: true
      t.belongs_to :workout_offering, index: true
      t.datetime :soft_deadline
      t.datetime :hard_deadline

      t.timestamps
    end
  end
end
