class RemoveQuestionTypeFromExercises < ActiveRecord::Migration
  def change
    remove_column :exercises, :question_type, :integer
  end
end
