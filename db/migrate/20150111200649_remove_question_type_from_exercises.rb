class RemoveQuestionTypeFromExercises < ActiveRecord::Migration[5.1]
  def change
    remove_column :exercises, :question_type, :integer
  end
end
