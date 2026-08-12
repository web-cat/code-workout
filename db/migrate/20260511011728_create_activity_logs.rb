class CreateActivityLogs < ActiveRecord::Migration[5.2]
  def change
    def fk_type(table)
      column = ActiveRecord::Base.connection.columns(table).find { |c| c.name == 'id' }
      column.sql_type.include?('bigint') ? :bigint : :integer
    rescue
      :bigint
    end

    create_table :activity_logs do |t|
      t.references :user, type: fk_type(:users), foreign_key: true
      t.references :exercise, type: fk_type(:exercises), foreign_key: true
      t.references :workout, type: fk_type(:workouts), foreign_key: true
      t.references :workout_offering, type: fk_type(:workout_offerings), foreign_key: true
      t.string :activity
      t.string :ip_address

      t.timestamps
    end
  end
end
