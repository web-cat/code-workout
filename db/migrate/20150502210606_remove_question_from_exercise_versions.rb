class RemoveQuestionFromExerciseVersions < ActiveRecord::Migration
  def up
    remove_column :exercise_versions, :question, :text
    change_column :choices, :answer, :text
  end

  def down
    add_column :exercise_versions, :question, :text
    change_column :choices, :answer, :string
  end
end
