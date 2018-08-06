class CreateMultipleChoicePromptAnswer < ActiveRecord::Migration
  def change
    create_table :multiple_choice_prompt_answers do |t|
    end

    create_table :choices_multiple_choice_prompt_answers, id: false do |t|
      t.belongs_to :choice, required: true
      t.belongs_to :multiple_choice_prompt_answer, required: true

      t.index [:choice_id, :multiple_choice_prompt_answer_id], unique: true,
        name: 'choices_multiple_choice_prompt_answers_idx'
    end

  end
end
