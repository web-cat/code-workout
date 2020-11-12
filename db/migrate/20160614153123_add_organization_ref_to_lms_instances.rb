class AddOrganizationRefToLmsInstances < ActiveRecord::Migration[5.1]
  def change
    add_reference :lms_instances, :organization, index: true
  end
end
