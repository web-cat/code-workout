class AddHideExamplesToCodingPrompt < ActiveRecord::Migration[5.1]
  def change
    add_column :coding_prompts, :hide_examples, :boolean, null: false, default: false
  end
end
