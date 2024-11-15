class RemoveAnswerFromMultipleChoicePromptAnswers < ActiveRecord::Migration[5.1]
  def change
    remove_column :multiple_choice_prompt_answers, :answer, :string
  end
end
