class CreateTraces < ActiveRecord::Migration
  def change
    create_table :traces do |t|
      t.string :exercise_trace
      t.references :answer, foreign_key: true

      t.timestamps
    end
  end
end
