class CreateChoices < ActiveRecord::Migration
  def change
    create_table :choices do |t|
      t.belongs_to :prompt, index: true, null: false
      t.string :answer
      t.integer :order
      t.text :feedback
      t.float :value

      t.timestamps
    end
  end
end
