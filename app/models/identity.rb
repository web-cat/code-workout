# == Schema Information
#
# Table name: identities
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  provider   :string(255)      default(""), not null
#  uid        :string(255)      default(""), not null
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_identities_on_uid_and_provider  (uid,provider)
#  index_identities_on_user_id           (user_id)
#

# =============================================================================
# Represents a user's external identity on an external devise-oriented
# authentication provider.  A single user object may be associated with
# multiple identities, each from a separate provider.
#
class Identity < ActiveRecord::Base

  #~ Relationships ............................................................

  belongs_to :user, inverse_of: :identities


  #~ Validation ...............................................................

  validates :user, presence: true
  validates :provider, presence: true
  validates :uid, presence: true

end
