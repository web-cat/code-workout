class RenamePromptToQuestionInPrompts < ActiveRecord::Migration[5.1]
  def change
    rename_column :prompts, :prompt, :question
  end
end
