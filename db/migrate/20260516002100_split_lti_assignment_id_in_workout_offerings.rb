class SplitLtiAssignmentIdInWorkoutOfferings < ActiveRecord::Migration[5.2]
  def fk_type(table)
    column = ActiveRecord::Base.connection.columns(table).find { |c| c.name == 'id' }
    column.sql_type.include?('bigint') ? :bigint : :integer
  rescue
    :bigint
  end

  def up
    # 1. Add lms_instance_id column with FK and index
    add_column :workout_offerings, :lms_instance_id, fk_type(:lms_instances)
    add_index :workout_offerings, :lms_instance_id
    add_foreign_key :workout_offerings, :lms_instances

    # 2. Data Migration: Resiliently split existing lti_assignment_id
    say "Splitting lti_assignment_id in workout_offerings..."
    WorkoutOffering.where("lti_assignment_id IS NOT NULL AND lti_assignment_id != ''").each do |wo|
      if wo.lti_assignment_id.include?('-')
        parts = wo.lti_assignment_id.split('-', 2)
        if parts.length == 2
          lms_id = parts[0]
          lti_id = parts[1]
          # Verify lms_id is numeric before assigning
          if lms_id =~ /\A\d+\z/
            wo.update_columns(lms_instance_id: lms_id.to_i, lti_assignment_id: lti_id)
          end
        end
      end
    end

    # 3. Add unique index on the combination
    # Note: This might fail if there are existing duplicates after splitting.
    # We should check for duplicates before adding this in a production scenario.
    add_index :workout_offerings, [:lms_instance_id, :lti_assignment_id], unique: true, name: 'idx_workout_offerings_on_lms_and_lti_assignment'
  end

  def down
    remove_index :workout_offerings, name: 'idx_workout_offerings_on_lms_and_lti_assignment'
    remove_foreign_key :workout_offerings, :lms_instances

    # Re-combine if lms_instance_id was present
    say "Re-combining lti_assignment_id in workout_offerings..."
    WorkoutOffering.where.not(lms_instance_id: nil).each do |wo|
      combined = "#{wo.lms_instance_id}-#{wo.lti_assignment_id}"
      wo.update_columns(lti_assignment_id: combined)
    end

    remove_index :workout_offerings, :lms_instance_id
    remove_column :workout_offerings, :lms_instance_id
  end
end
