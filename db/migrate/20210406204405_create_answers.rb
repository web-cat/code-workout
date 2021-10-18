class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.text :StudentCode
      t.references :popexercise, foreign_key: true

      t.timestamps
    end
  end
end
