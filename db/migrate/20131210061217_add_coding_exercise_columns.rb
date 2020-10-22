class AddCodingExerciseColumns < ActiveRecord::Migration[5.1]
  def change
    add_column :exercises, :starter_code, :text

    create_table :test_cases do |t|
      t.string :test_script, null: false
      t.belongs_to :exercise, null: false, index: true
      t.timestamps
    end
  end
end
