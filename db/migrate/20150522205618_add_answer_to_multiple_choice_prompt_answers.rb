class AddAnswerToMultipleChoicePromptAnswers < ActiveRecord::Migration[5.1]
  def change
    add_column :multiple_choice_prompt_answers, :answer, :string
  end
end
