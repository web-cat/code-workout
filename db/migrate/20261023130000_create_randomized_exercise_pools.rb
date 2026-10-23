class CreateRandomizedExercisePools < ActiveRecord::Migration[5.2]
  def fk_type(table)
    column = ActiveRecord::Base.connection.columns(table).find { |c| c.name == 'id' }
    column.sql_type.include?('bigint') ? :bigint : :integer
  rescue
    :bigint
  end

  class MigrationExerciseWorkout < ActiveRecord::Base
    self.table_name = 'exercise_workouts'
  end

  class MigrationWorkout < ActiveRecord::Base
    self.table_name = 'workouts'
  end

  class MigrationExercisePool < ActiveRecord::Base
    self.table_name = 'exercise_pools'
  end

  class MigrationExercisePoolItem < ActiveRecord::Base
    self.table_name = 'exercise_pool_items'
  end

  class MigrationWorkoutScore < ActiveRecord::Base
    self.table_name = 'workout_scores'
  end

  class MigrationWorkoutScoreExercise < ActiveRecord::Base
    self.table_name = 'workout_score_exercises'
  end

  def up
    create_table :exercise_pools do |t|
      t.references :workout, type: fk_type(:workouts), foreign_key: true, null: false
      t.string :name
      t.integer :position, null: false
      t.integer :select_count, default: 1, null: false
      t.float :points, default: 1.0, null: false

      t.timestamps
    end

    add_index :exercise_pools, [:workout_id, :position], name: 'index_exercise_pools_on_workout_id_and_position'

    create_table :exercise_pool_items do |t|
      t.references :exercise_pool, type: fk_type(:exercise_pools), foreign_key: true, null: false
      t.references :exercise, type: fk_type(:exercises), foreign_key: true, null: false
      t.integer :position, default: 1, null: false

      t.timestamps
    end

    add_index :exercise_pool_items, [:exercise_pool_id, :exercise_id], unique: true, name: 'idx_pool_items_on_pool_and_exercise'

    create_table :workout_score_exercises do |t|
      t.references :workout_score, type: fk_type(:workout_scores), foreign_key: true, null: false
      t.references :exercise, type: fk_type(:exercises), foreign_key: true, null: false
      t.references :exercise_pool, type: fk_type(:exercise_pools), foreign_key: true, null: true
      t.integer :position, null: false
      t.float :points, default: 1.0, null: false

      t.timestamps
    end

    add_index :workout_score_exercises, [:workout_score_id, :position], unique: true, name: 'idx_ws_exercises_on_ws_and_pos'
    add_index :workout_score_exercises, [:workout_score_id, :exercise_id], name: 'idx_ws_exercises_on_ws_and_ex'

    backfill_data
  end

  def down
    drop_table :workout_score_exercises if table_exists?(:workout_score_exercises)
    drop_table :exercise_pool_items if table_exists?(:exercise_pool_items)
    drop_table :exercise_pools if table_exists?(:exercise_pools)
  end

  private

  def backfill_data
    # 1. Backfill exercise_workouts into 1-exercise pools (k = 1)
    MigrationWorkout.find_each do |w|
      ews = MigrationExerciseWorkout.where(workout_id: w.id).order(:position, :id)
      ews.each_with_index do |ew, idx|
        pool = MigrationExercisePool.create!(
          workout_id: w.id,
          name: nil,
          position: idx + 1,
          select_count: 1,
          points: ew.points || 1.0,
          created_at: ew.created_at || Time.current,
          updated_at: ew.updated_at || Time.current
        )

        MigrationExercisePoolItem.create!(
          exercise_pool_id: pool.id,
          exercise_id: ew.exercise_id,
          position: 1,
          created_at: ew.created_at || Time.current,
          updated_at: ew.updated_at || Time.current
        )
      end
    end

    # 2. Backfill existing workout_scores into workout_score_exercises
    MigrationWorkoutScore.find_each do |ws|
      pools = MigrationExercisePool.where(workout_id: ws.workout_id).order(:position, :id)
      pools.each_with_index do |pool, idx|
        item = MigrationExercisePoolItem.find_by(exercise_pool_id: pool.id)
        next unless item

        MigrationWorkoutScoreExercise.create!(
          workout_score_id: ws.id,
          exercise_id: item.exercise_id,
          exercise_pool_id: pool.id,
          position: idx + 1,
          points: pool.points,
          created_at: ws.created_at || Time.current,
          updated_at: ws.updated_at || Time.current
        )
      end
    end
  end
end
