class AddLtiUserIdIndexToLtiIdentities < ActiveRecord::Migration[4.2]
  def change
    add_index :lti_identities, :lti_user_id
  end
end
