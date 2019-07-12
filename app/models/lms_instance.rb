# == Schema Information
#
# Table name: lms_instances
#
#  id              :integer          not null, primary key
#  consumer_key    :string(255)
#  consumer_secret :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  url             :string(255)
#  lms_type_id     :integer
#  organization_id :integer
#
# Indexes
#
#  index_lms_instances_on_organization_id  (organization_id)
#  index_lms_instances_on_url              (url) UNIQUE
#  lms_instances_lms_type_id_fk            (lms_type_id)
#

class LmsInstance < ActiveRecord::Base
  belongs_to  :lms_type, inverse_of: :lms_instances
  belongs_to :organization
  has_many :course_offerings, inverse_of: :lms_instance
  has_many :lti_identities
  has_many :lti_workouts, inverse_of: :lms_instnace
  #~ Validation ...............................................................

  validates_presence_of :url
end
