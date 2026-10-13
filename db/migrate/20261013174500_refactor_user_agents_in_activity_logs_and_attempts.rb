class RefactorUserAgentsInActivityLogsAndAttempts < ActiveRecord::Migration[5.2]
  def fk_type(table)
    column = ActiveRecord::Base.connection.columns(table).find { |c| c.name == 'id' }
    column.sql_type.include?('bigint') ? :bigint : :integer
  rescue
    :bigint
  end

  def up
    # 1. Refactor activity_logs
    unless column_exists?(:activity_logs, :user_agent_id)
      add_column :activity_logs, :user_agent_id, fk_type(:user_agents)
      add_index :activity_logs, :user_agent_id
      add_foreign_key :activity_logs, :user_agents rescue nil
    end

    if column_exists?(:activity_logs, :user_agent)
      # Populate user_agents from distinct non-empty activity log user agents
      distinct_uas = select_values(
        "SELECT DISTINCT user_agent FROM activity_logs WHERE user_agent IS NOT NULL AND TRIM(user_agent) != ''"
      )
      distinct_uas.each do |raw_ua|
        UserAgent.find_or_create_by_raw(raw_ua)
      end

      # Backfill activity_logs.user_agent_id via SHA-256 hash
      execute <<-SQL
        UPDATE activity_logs a
        JOIN user_agents u ON u.user_agent_hash = SHA2(TRIM(a.user_agent), 256)
        SET a.user_agent_id = u.id
        WHERE a.user_agent IS NOT NULL AND TRIM(a.user_agent) != ''
      SQL

      remove_column :activity_logs, :user_agent
    end

    # 2. Refactor attempts
    if column_exists?(:attempts, :user_agent)
      distinct_attempt_uas = select_values(
        "SELECT DISTINCT user_agent FROM attempts WHERE user_agent IS NOT NULL AND TRIM(user_agent) != ''"
      )
      distinct_attempt_uas.each do |raw_ua|
        UserAgent.find_or_create_by_raw(raw_ua)
      end

      unless column_exists?(:attempts, :user_agent_id)
        add_column :attempts, :user_agent_id, fk_type(:user_agents)
        add_index :attempts, :user_agent_id
        add_foreign_key :attempts, :user_agents rescue nil
      end

      execute <<-SQL
        UPDATE attempts a
        JOIN user_agents u ON u.user_agent_hash = SHA2(TRIM(a.user_agent), 256)
        SET a.user_agent_id = u.id
        WHERE a.user_agent IS NOT NULL AND TRIM(a.user_agent) != ''
      SQL

      remove_column :attempts, :user_agent
    else
      unless column_exists?(:attempts, :user_agent_id)
        add_column :attempts, :user_agent_id, fk_type(:user_agents)
        add_index :attempts, :user_agent_id
        add_foreign_key :attempts, :user_agents rescue nil
      end
    end
  end

  def down
    # Restore activity_logs.user_agent
    unless column_exists?(:activity_logs, :user_agent)
      add_column :activity_logs, :user_agent, :text
      execute <<-SQL
        UPDATE activity_logs a
        JOIN user_agents u ON a.user_agent_id = u.id
        SET a.user_agent = u.raw_user_agent
      SQL
    end

    if column_exists?(:activity_logs, :user_agent_id)
      remove_foreign_key :activity_logs, :user_agents rescue nil
      remove_index :activity_logs, :user_agent_id rescue nil
      remove_column :activity_logs, :user_agent_id
    end

    # Restore attempts.user_agent
    unless column_exists?(:attempts, :user_agent)
      add_column :attempts, :user_agent, :text
      execute <<-SQL
        UPDATE attempts a
        JOIN user_agents u ON a.user_agent_id = u.id
        SET a.user_agent = u.raw_user_agent
      SQL
    end

    if column_exists?(:attempts, :user_agent_id)
      remove_foreign_key :attempts, :user_agents rescue nil
      remove_index :attempts, :user_agent_id rescue nil
      remove_column :attempts, :user_agent_id
    end
  end
end
