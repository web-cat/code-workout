class FixClassNameInCodingQuestions < ActiveRecord::Migration[5.1]
  def change
    rename_column :coding_questions, :base_class, :class_name
  end
end
