class RefactorUserAgentsInWorkoutScoresAndErrors < ActiveRecord::Migration[5.2]
  def fk_type(table)
    column = ActiveRecord::Base.connection.columns(table).find { |c| c.name == 'id' }
    column.sql_type.include?('bigint') ? :bigint : :integer
  rescue
    :bigint
  end

  def up
    # 1. Refactor workout_scores
    unless column_exists?(:workout_scores, :last_user_agent_id)
      add_column :workout_scores, :last_user_agent_id, fk_type(:user_agents)
      add_index :workout_scores, :last_user_agent_id
      add_foreign_key :workout_scores, :user_agents, column: :last_user_agent_id rescue nil
    end

    if column_exists?(:workout_scores, :last_user_agent)
      distinct_ws_uas = select_values(
        "SELECT DISTINCT last_user_agent FROM workout_scores WHERE last_user_agent IS NOT NULL AND TRIM(last_user_agent) != ''"
      )
      distinct_ws_uas.each do |raw_ua|
        UserAgent.find_or_create_by_raw(raw_ua)
      end

      execute <<-SQL
        UPDATE workout_scores ws
        JOIN user_agents u ON u.user_agent_hash = SHA2(TRIM(ws.last_user_agent), 256)
        SET ws.last_user_agent_id = u.id
        WHERE ws.last_user_agent IS NOT NULL AND TRIM(ws.last_user_agent) != ''
      SQL

      remove_column :workout_scores, :last_user_agent
    end

    # 2. Refactor errors
    unless column_exists?(:errors, :user_agent_id)
      add_column :errors, :user_agent_id, fk_type(:user_agents)
      add_index :errors, :user_agent_id
      add_foreign_key :errors, :user_agents rescue nil
    end

    if column_exists?(:errors, :user_agent)
      distinct_error_uas = select_values(
        "SELECT DISTINCT user_agent FROM errors WHERE user_agent IS NOT NULL AND TRIM(user_agent) != ''"
      )
      distinct_error_uas.each do |raw_ua|
        UserAgent.find_or_create_by_raw(raw_ua)
      end

      execute <<-SQL
        UPDATE errors e
        JOIN user_agents u ON u.user_agent_hash = SHA2(TRIM(e.user_agent), 256)
        SET e.user_agent_id = u.id
        WHERE e.user_agent IS NOT NULL AND TRIM(e.user_agent) != ''
      SQL

      remove_column :errors, :user_agent
    end
  end

  def down
    # Restore workout_scores.last_user_agent
    unless column_exists?(:workout_scores, :last_user_agent)
      add_column :workout_scores, :last_user_agent, :text
      execute <<-SQL
        UPDATE workout_scores ws
        JOIN user_agents u ON ws.last_user_agent_id = u.id
        SET ws.last_user_agent = u.raw_user_agent
      SQL
    end

    if column_exists?(:workout_scores, :last_user_agent_id)
      remove_foreign_key :workout_scores, column: :last_user_agent_id rescue nil
      remove_index :workout_scores, :last_user_agent_id rescue nil
      remove_column :workout_scores, :last_user_agent_id
    end

    # Restore errors.user_agent
    unless column_exists?(:errors, :user_agent)
      add_column :errors, :user_agent, :text
      execute <<-SQL
        UPDATE errors e
        JOIN user_agents u ON e.user_agent_id = u.id
        SET e.user_agent = u.raw_user_agent
      SQL
    end

    if column_exists?(:errors, :user_agent_id)
      remove_foreign_key :errors, :user_agents rescue nil
      remove_index :errors, :user_agent_id rescue nil
      remove_column :errors, :user_agent_id
    end
  end
end
