class AddLmsTypeIdToLmsInstance < ActiveRecord::Migration[5.1]
  def change
    add_column :lms_instances, :lms_type_id, :integer
    add_foreign_key :lms_instances, :lms_types
  end
end
