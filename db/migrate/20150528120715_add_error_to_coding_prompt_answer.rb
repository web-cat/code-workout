class AddErrorToCodingPromptAnswer < ActiveRecord::Migration[5.1]
  def change
    add_column :coding_prompt_answers, :error, :text
  end
end
