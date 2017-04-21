class AddLmsTypeIdToLmsInstance < ActiveRecord::Migration
  def change
    add_column :lms_instances, :lms_type_id, :integer
    add_foreign_key :lms_instances, :lms_types
  end
end
