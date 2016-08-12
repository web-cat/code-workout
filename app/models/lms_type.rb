class LmsType < ActiveRecord::Base
  #~ Relationships ............................................................
has_many :lms_instances, inverse_of: :lms_types

#~ Validation ...............................................................

validates :name, presence: true,
  uniqueness: { case_sensitive: true }
end
