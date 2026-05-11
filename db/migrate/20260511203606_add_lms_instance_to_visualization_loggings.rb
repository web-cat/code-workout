class AddLmsInstanceToVisualizationLoggings < ActiveRecord::Migration[5.2]
  def change
    add_column :visualization_loggings, :lms_instance_id, :bigint
    add_index :visualization_loggings, :lms_instance_id
    add_column :visualization_loggings, :lti_launch, :boolean
  end
end
