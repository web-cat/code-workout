class CreateWorkoutPolicy < ActiveRecord::Migration
  def change
    create_table :workout_policies do |t|
      t.boolean :hide_thumbnails_before_start
      t.boolean :hide_feedback_before_finish
      t.boolean :hide_compilation_feedback_before_finish
      t.boolean :no_review_before_close
      t.boolean :hide_feedback_in_review_before_close
      t.boolean :hide_thumbnails_in_review_before_close
      t.boolean :no_hints
      t.boolean :no_faq
      t.string :name

      t.timestamps
    end

    change_table :workout_offerings do |t|
      t.belongs_to :workout_policy, index: true
    end
  end
end
