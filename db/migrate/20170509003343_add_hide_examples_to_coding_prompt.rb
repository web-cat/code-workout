class AddHideExamplesToCodingPrompt < ActiveRecord::Migration
  def change
    add_column :coding_prompts, :hide_examples, :boolean, null: false, default: false
  end
end
