class CreateCodingQuestions < ActiveRecord::Migration
  def change
    create_table :coding_questions do |t|
      t.string :base_class
      t.text :wrapper_code
      t.text :test_script

      t.timestamps
    end
    add_reference :coding_questions, :exercise, index: true
  end
end
