class AddLmsTypeIdToLmsInstance < ActiveRecord::Migration[5.1]
  def change
    add_reference :lms_instances, :lms_type, foreign_key: true
  end
end
