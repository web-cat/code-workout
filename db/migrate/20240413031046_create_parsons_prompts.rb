class CreateParsonsPrompts < ActiveRecord::Migration[6.1]
  def change
    create_table :parsons_prompts do |t|
      t.text :title
      t.text :instructions
      t.string :exercise_id
      t.json :assets
      t.references :exercise_version, null: false, foreign_key: true
      t.timestamps
    end
  end
end