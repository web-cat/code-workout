class AddLtiUserIdIndexToLtiIdentities < ActiveRecord::Migration
  def change
    add_index :lti_identities, :lti_user_id
  end
end
