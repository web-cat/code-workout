class CreateParsonsPrompts < ActiveRecord::Migration[5.2]
  def change
    create_table :parsons_prompts do |t|
      t.text :pif_json
      t.text :wrapper_code
      t.text :test_script
      t.text :starter_code
      t.string :class_name
      t.string :method_name
      t.boolean :hide_examples
    end
  end
end
