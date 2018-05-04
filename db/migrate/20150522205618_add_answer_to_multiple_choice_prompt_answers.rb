class AddAnswerToMultipleChoicePromptAnswers < ActiveRecord::Migration
  def change
    add_column :multiple_choice_prompt_answers, :answer, :string
  end
end
