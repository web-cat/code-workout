class ChangeScoreInAttempts < ActiveRecord::Migration[5.1]
  def change
    change_column :attempts, :score, :float, default: 0.0
  end
end
