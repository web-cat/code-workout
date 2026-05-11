class AddLmsInstanceToAttemptsAndLogs < ActiveRecord::Migration[5.2]
  def change
    add_column :attempts, :lms_instance_id, :bigint
    add_column :attempts, :lti_launch, :boolean, default: false
    add_index :attempts, :lms_instance_id

    add_column :activity_logs, :lms_instance_id, :bigint
    add_column :activity_logs, :lti_launch, :boolean, default: false
    add_index :activity_logs, :lms_instance_id
  end
end
