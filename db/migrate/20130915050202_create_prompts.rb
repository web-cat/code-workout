class CreatePrompts < ActiveRecord::Migration
  def change
    create_table :prompts do |t|
      t.belongs_to :exercise, index: true, null: false
      t.belongs_to :language, index: true, null: false
      t.text :instruction, null: false
      t.integer :order, null: false
      t.integer :max_user_attempts
      t.integer :attempts
      t.float :correct
      t.text :feedback
      t.float :difficulty, null: false
      t.float :discrimination, null: false
      t.integer :type, null: false

      #Single table inheritance fields.........................................

      #multiple choice question specific fields
      t.boolean :allow_multiple
      t.boolean :is_scrambled
      
      t.timestamps
    end
  end
end
