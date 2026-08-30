class AddAttemptStateToParsonsPromptAnswers < ActiveRecord::Migration[5.2]
  def change
    add_column :parsons_prompt_answers, :attempt_state, :text
  end
end
