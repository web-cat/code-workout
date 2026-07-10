class AddWorkoutScoreToVisualizationLoggings < ActiveRecord::Migration[5.2]
  def change
    def fk_type(table)
      column = ActiveRecord::Base.connection.columns(table).find { |c| c.name == 'id' }
      column.sql_type.include?('bigint') ? :bigint : :integer
    rescue
      :bigint
    end

    add_column :visualization_loggings, :workout_score_id, fk_type(:workout_scores)
    add_index :visualization_loggings, :workout_score_id
  end
end
