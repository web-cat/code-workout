class AddWorkoutScoreToActivityLogs < ActiveRecord::Migration[5.2]
  def change
    def fk_type(table)
      column = ActiveRecord::Base.connection.columns(table).find { |c| c.name == 'id' }
      column.sql_type.include?('bigint') ? :bigint : :integer
    rescue
      :bigint
    end

    add_column :activity_logs, :workout_score_id, fk_type(:workout_scores)
    add_index :activity_logs, :workout_score_id
  end
end
