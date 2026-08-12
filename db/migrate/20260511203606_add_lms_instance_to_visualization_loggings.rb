class AddLmsInstanceToVisualizationLoggings < ActiveRecord::Migration[5.2]
  def change
    def fk_type(table)
      column = ActiveRecord::Base.connection.columns(table).find { |c| c.name == 'id' }
      column.sql_type.include?('bigint') ? :bigint : :integer
    rescue
      :bigint
    end

    add_column :visualization_loggings, :lms_instance_id, fk_type(:lms_instances)
    add_index :visualization_loggings, :lms_instance_id
    add_column :visualization_loggings, :lti_launch, :boolean
  end
end
