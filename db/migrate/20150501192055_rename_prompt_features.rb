class RenamePromptFeatures < ActiveRecord::Migration
  def change
    change_table :prompts do |t|
      t.remove :language_id, :integer
      t.rename :instruction, :prompt
      t.remove :max_user_attempts, :integer
      t.rename :attempts, :attempt_count
      t.rename :correct, :correct_count
      t.remove :type, :integer
      t.remove :allow_multiple, :boolean
      t.actable
      t.index :actable_id, unique: true
    end

    rename_table :coding_questions, :coding_prompts
    change_table :coding_prompts do |t|
      t.remove :exercise_version_id, :integer
    end

    create_table :multiple_choice_prompts do |t|
      t.boolean :allow_multiple, null: false, default: false
      t.boolean :is_scrambled, null: false, default: true
    end

    change_table :exercise_versions do |t|
      t.remove :feedback, :text
      t.remove :priority, :integer
      t.rename :count_attempts, :attempt_count
      t.rename :count_correct, :correct_count
      t.remove :mcq_allow_multiple, :boolean
      t.remove :mcq_is_scrambled, :boolean
    end
  end
end
