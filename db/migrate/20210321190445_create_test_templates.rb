class CreateTestTemplates < ActiveRecord::Migration
  def change
    create_table :test_templates do |t|
      t.text :code_template
      t.references :test_case, index: true, foreign_key: true, null: true

      t.timestamps null: false
    end
  end
end
