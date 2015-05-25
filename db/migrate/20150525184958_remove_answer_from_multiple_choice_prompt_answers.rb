class RemoveAnswerFromMultipleChoicePromptAnswers < ActiveRecord::Migration
  def change
    remove_column :multiple_choice_prompt_answers, :answer, :string
  end
end
