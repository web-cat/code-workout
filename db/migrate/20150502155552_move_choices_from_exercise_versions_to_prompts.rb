class MoveChoicesFromExerciseVersionsToPrompts < ActiveRecord::Migration
  def up
    remove_foreign_key :choices, :exercise_versions
    Choice.delete_all
    rename_column :choices, :exercise_version_id, :multiple_choice_prompt_id
    add_foreign_key :choices, :multiple_choice_prompts
  end

  def down
    remove_foreign_key :choices, :multiple_choice_prompts
    rename_column :choices, :multiple_choice_prompt_id, :exercise_version_id
    add_foreign_key :choices, :exercise_versions
  end
end
