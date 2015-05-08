class RenamePromptToQuestionInPrompts < ActiveRecord::Migration
  def change
    rename_column :prompts, :prompt, :question
  end
end
