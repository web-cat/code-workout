class CreatePrompts < ActiveRecord::Migration
  def change
    create_table :prompts do |t|
      t.belongs_to :question, index: true, null: false
      t.belongs_to :language, index: true, null: false
      t.belongs_to :prompt_type, index: true, null: false
      t.text :instruction, null: false
      t.integer :order, null: false
      t.integer :max_attempts
      t.text :feedback
      t.float :difficulty, null: false
      t.float :discrimination, null: false
      t.boolean :allow_multiple
      t.boolean :is_scrambled
      
      t.timestamps
    end

    create_table :prompt_types do |t|
      t.string :name

      t.timestamps
    end

    create_table :languages do |t|
      t.string :name

      t.timestamps
    end
  end
end
