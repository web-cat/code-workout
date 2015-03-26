# == Schema Information
#
# Table name: identities
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  provider   :string(255)      not null
#  uid        :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_identities_on_uid_and_provider  (uid,provider)
#  index_identities_on_user_id           (user_id)
#

class Identity < ActiveRecord::Base

  #~ Relationships ............................................................

  belongs_to :user, inverse_of: :identities


  #~ Validation ...............................................................

  validates :user, presence: true
  validates :provider, presence: true
  validates :uid, presence: true

end
