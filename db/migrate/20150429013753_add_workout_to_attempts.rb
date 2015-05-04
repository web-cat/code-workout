class AddWorkoutToAttempts < ActiveRecord::Migration
  def change
    add_reference :attempts, :workout, index: true
  end
end
