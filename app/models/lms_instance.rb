class LmsInstance < ActiveRecord::Base
  belongs_to  :lms_type, inverse_of: :lms_instances
  #~ Validation ...............................................................

  validates_presence_of :url
end
