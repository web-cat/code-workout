class AddErrorToCodingPromptAnswer < ActiveRecord::Migration
  def change
    add_column :coding_prompt_answers, :error, :text
  end
end
