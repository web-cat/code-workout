class ChangeScoreInAttempts < ActiveRecord::Migration
  def change
    change_column :attempts, :score, :number, default: 0.0
  end
end
