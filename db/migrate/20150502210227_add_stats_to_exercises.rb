class AddStatsToExercises < ActiveRecord::Migration[5.1]
  def change
    change_table :exercises do |t|
      t.integer  :attempt_count,  null: false, default: 0
      t.float    :correct_count,  null: false, default: 0.0
      t.float    :difficulty,     null: false, default: 0.0
      t.float    :discrimination, null: false, default: 0.0
    end
  end
end
