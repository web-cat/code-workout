class MakeScoreToKeepNullableOnWorkoutOfferings < ActiveRecord::Migration[5.2]
  def up
    change_column_null :workout_offerings, :score_to_keep, true
    change_column_default :workout_offerings, :score_to_keep, nil
  end

  def down
    change_column_default :workout_offerings, :score_to_keep, false
    change_column_null :workout_offerings, :score_to_keep, false, false
  end
end
