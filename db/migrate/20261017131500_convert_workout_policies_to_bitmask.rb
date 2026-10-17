class ConvertWorkoutPoliciesToBitmask < ActiveRecord::Migration[5.2]
  def up
    add_column :workout_offerings, :policy_values, :bigint, default: 0, null: false
    add_column :workout_offerings, :policy_mask, :bigint, default: 0, null: false

    # Backfill policy_values and policy_mask from existing workout_policies
    if table_exists?(:workout_policies)
      execute <<-SQL
        UPDATE workout_offerings wo
        INNER JOIN workout_policies wp ON wo.workout_policy_id = wp.id
        SET wo.policy_values = (
          (CASE WHEN wp.hide_compilation_feedback_before_finish = 1 THEN 1 ELSE 0 END) |
          (CASE WHEN wp.hide_feedback_before_finish = 1 THEN 2 ELSE 0 END) |
          (CASE WHEN wp.hide_feedback_in_review_before_close = 1 THEN 4 ELSE 0 END) |
          (CASE WHEN wp.hide_score_before_finish = 1 THEN 8 ELSE 0 END) |
          (CASE WHEN wp.hide_score_in_review_before_close = 1 THEN 16 ELSE 0 END) |
          (CASE WHEN wp.hide_thumbnails_before_start = 1 THEN 32 ELSE 0 END) |
          (CASE WHEN wp.hide_thumbnails_in_review_before_close = 1 THEN 64 ELSE 0 END) |
          (CASE WHEN wp.invisible_before_review = 1 THEN 128 ELSE 0 END) |
          (CASE WHEN wp.no_faq = 1 THEN 256 ELSE 0 END) |
          (CASE WHEN wp.no_hints = 1 THEN 512 ELSE 0 END) |
          (CASE WHEN wp.no_review_before_close = 1 THEN 1024 ELSE 0 END) |
          (CASE WHEN wp.see_answers = 1 THEN 2048 ELSE 0 END)
        ),
        wo.policy_mask = 4095
      SQL
    end

    # Offerings with no policy previously get the system default (see_answers = true => 2048, mask = 4095)
    execute <<-SQL
      UPDATE workout_offerings
      SET policy_values = 2048, policy_mask = 4095
      WHERE policy_mask = 0
    SQL

    if foreign_key_exists?(:workout_offerings, :workout_policies)
      remove_foreign_key :workout_offerings, :workout_policies
    elsif foreign_key_exists?(:workout_offerings, name: 'workout_offerings_workout_policy_id_fk')
      remove_foreign_key :workout_offerings, name: 'workout_offerings_workout_policy_id_fk'
    end

    if index_exists?(:workout_offerings, :workout_policy_id)
      remove_index :workout_offerings, :workout_policy_id
    end

    if column_exists?(:workout_offerings, :workout_policy_id)
      remove_column :workout_offerings, :workout_policy_id
    end

    if table_exists?(:workout_policies)
      drop_table :workout_policies
    end
  end

  def down
    create_table :workout_policies do |t|
      t.boolean :hide_compilation_feedback_before_finish, default: false, null: false
      t.boolean :hide_feedback_before_finish,             default: false, null: false
      t.boolean :hide_feedback_in_review_before_close,    default: false, null: false
      t.boolean :hide_score_before_finish,                default: false, null: false
      t.boolean :hide_score_in_review_before_close,       default: false, null: false
      t.boolean :hide_thumbnails_before_start,            default: false, null: false
      t.boolean :hide_thumbnails_in_review_before_close,  default: false, null: false
      t.boolean :invisible_before_review,                 default: false, null: false
      t.boolean :no_faq,                                  default: false, null: false
      t.boolean :no_hints,                                default: false, null: false
      t.boolean :no_review_before_close,                  default: false, null: false
      t.boolean :see_answers,                             default: true,  null: false
      t.timestamps null: false
    end

    def fk_type(table)
      column = ActiveRecord::Base.connection.columns(table).find { |c| c.name == 'id' }
      column.sql_type.include?('bigint') ? :bigint : :integer
    rescue
      :bigint
    end

    add_column :workout_offerings, :workout_policy_id, fk_type(:workout_policies)
    add_index :workout_offerings, :workout_policy_id
    add_foreign_key :workout_offerings, :workout_policies, name: 'workout_offerings_workout_policy_id_fk'

    # Recreate policies from bitmasks
    execute <<-SQL
      INSERT INTO workout_policies (
        id,
        hide_compilation_feedback_before_finish,
        hide_feedback_before_finish,
        hide_feedback_in_review_before_close,
        hide_score_before_finish,
        hide_score_in_review_before_close,
        hide_thumbnails_before_start,
        hide_thumbnails_in_review_before_close,
        invisible_before_review,
        no_faq,
        no_hints,
        no_review_before_close,
        see_answers,
        created_at,
        updated_at
      )
      SELECT
        id,
        (policy_values & 1) != 0,
        (policy_values & 2) != 0,
        (policy_values & 4) != 0,
        (policy_values & 8) != 0,
        (policy_values & 16) != 0,
        (policy_values & 32) != 0,
        (policy_values & 64) != 0,
        (policy_values & 128) != 0,
        (policy_values & 256) != 0,
        (policy_values & 512) != 0,
        (policy_values & 1024) != 0,
        (policy_values & 2048) != 0,
        NOW(),
        NOW()
      FROM workout_offerings
    SQL

    execute <<-SQL
      UPDATE workout_offerings SET workout_policy_id = id
    SQL

    remove_column :workout_offerings, :policy_values
    remove_column :workout_offerings, :policy_mask
  end
end
