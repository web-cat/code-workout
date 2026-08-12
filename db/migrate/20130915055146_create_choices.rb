class CreateChoices < ActiveRecord::Migration[5.1]
  def change
    create_table :choices do |t|
      t.belongs_to :exercise, index: true, null: false
      t.string :answer
      t.integer :order
      t.text :feedback
      t.float :value

      t.timestamps
    end
  end
end
