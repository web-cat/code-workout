class FixClassNameInCodingQuestions < ActiveRecord::Migration
  def change
    rename_column :coding_questions, :base_class, :class_name
  end
end
