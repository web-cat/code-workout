class RenamePromptFeatures < ActiveRecord::Migration[5.1]
  def change
    change_table :prompts do |t|
      t.remove :language_id
      t.rename :instruction, :prompt
      t.remove :max_user_attempts
      t.rename :attempts, :attempt_count
      t.rename :correct, :correct_count
      t.remove :type
      t.remove :allow_multiple
      t.actable
      t.index :actable_id, unique: true
    end

    rename_table :coding_questions, :coding_prompts
    change_table :coding_prompts do |t|
      t.remove :exercise_version_id
    end

    create_table :multiple_choice_prompts do |t|
      t.boolean :allow_multiple, null: false, default: false
      t.boolean :is_scrambled, null: false, default: true
    end

    change_table :exercise_versions do |t|
      t.remove :feedback
      t.remove :priority
      t.rename :count_attempts, :attempt_count
      t.rename :count_correct, :correct_count
      t.remove :mcq_allow_multiple
      t.remove :mcq_is_scrambled
    end
  end
end
