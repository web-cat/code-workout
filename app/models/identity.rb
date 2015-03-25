# == Schema Information
#
# Table name: identities
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  provider   :string(255)
#  uid        :string(255)
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_identities_on_user_id  (user_id)
#

class Identity < ActiveRecord::Base

  #~ Relationships ............................................................

  belongs_to :user, inverse_of: :identities


  #~ Validation ...............................................................

  validates :user, presence: true
  validates :provider, presence: true, allows_blank: false
  validates :uid, presence: true, allows_blank: false

end
