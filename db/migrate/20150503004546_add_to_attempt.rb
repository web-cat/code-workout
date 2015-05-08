class AddToAttempt < ActiveRecord::Migration
  def change
    change_table :attempts do |t|
      t.belongs_to :workout_score
      t.integer :active_score_id

      t.index :workout_score_id
      t.index :active_score_id
    end
    change_column :attempts, :score, :float
  end

  def down
    change_table :attempts do |t|
      t.remove :workout_score_id
      t.remove :active_score_id
    end
  end
end
