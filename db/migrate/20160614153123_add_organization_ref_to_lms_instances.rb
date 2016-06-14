class AddOrganizationRefToLmsInstances < ActiveRecord::Migration
  def change
    add_reference :lms_instances, :organization, index: true
  end
end
