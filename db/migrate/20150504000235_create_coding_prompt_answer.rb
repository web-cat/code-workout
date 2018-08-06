class CreateCodingPromptAnswer < ActiveRecord::Migration
  def change
    remove_column :attempts, :answer, :text
    remove_column :attempts, :workout_offering_id, :integer

    create_table :coding_prompt_answers do |t|
      t.text :answer, null: false
    end

    change_table :test_case_results do |t|
      t.belongs_to :coding_prompt_answer, required: true
      t.index :coding_prompt_answer_id
    end

    add_index :prompt_answers, :actable_id, unique: true
  end
end
