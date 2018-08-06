# == Schema Information
#
# Table name: lms_types
#
#  id         :integer          not null, primary key
#  name       :string(255)      default(""), not null
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_lms_types_on_name  (name) UNIQUE
#

class LmsType < ActiveRecord::Base
  #~ Relationships ............................................................
has_many :lms_instances, inverse_of: :lms_types

#~ Validation ...............................................................

validates :name, presence: true,
  uniqueness: { case_sensitive: true }
end
