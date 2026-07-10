class CreateParsonsPromptAnswers < ActiveRecord::Migration[5.2]
  def change
    create_table :parsons_prompt_answers do |t|
      t.text :answer
      t.text :error
      t.integer :error_line_no
    end
  end
end
