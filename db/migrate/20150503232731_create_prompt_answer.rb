class CreatePromptAnswer < ActiveRecord::Migration
  def change
    create_table :prompt_answers do |t|
      t.belongs_to :attempt, required: true
      t.belongs_to :prompt, required: true
      t.actable

      t.index :attempt_id
      t.index :prompt_id
      t.index [:attempt_id, :prompt_id], unique: true
    end
  end
end
