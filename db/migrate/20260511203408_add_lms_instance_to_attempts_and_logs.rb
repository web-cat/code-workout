class AddLmsInstanceToAttemptsAndLogs < ActiveRecord::Migration[5.2]
  def change
    def fk_type(table)
      column = ActiveRecord::Base.connection.columns(table).find { |c| c.name == 'id' }
      column.sql_type.include?('bigint') ? :bigint : :integer
    rescue
      :bigint
    end

    add_column :attempts, :lms_instance_id, fk_type(:lms_instances)
    add_column :attempts, :lti_launch, :boolean, default: false
    add_index :attempts, :lms_instance_id

    add_column :activity_logs, :lms_instance_id, fk_type(:lms_instances)
    add_column :activity_logs, :lti_launch, :boolean, default: false
    add_index :activity_logs, :lms_instance_id
  end
end
