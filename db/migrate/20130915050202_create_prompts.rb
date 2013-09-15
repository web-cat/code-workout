class CreatePrompts < ActiveRecord::Migration
  def change
    create_table :prompts do |t|
      t.belongs_to :exercise, index: true, null: false
      t.has_one :language, index: true, null: false
      t.has_one :prompt_type, index: true, null: false
      t.text :instruction, null: false
      t.integer :order, null: false
      t.integer :max_attempts
      t.integer :max_attempts
      t.float :correct
      t.text :feedback
      t.float :difficulty, null: false
      t.float :discrimination, null: false
      
      t.timestamps
    end

    create_table :languages do |t|
      t.string :name

      t.timestamps
    end
  end
end
