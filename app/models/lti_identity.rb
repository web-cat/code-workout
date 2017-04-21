class LtiIdentity < ActiveRecord::Base
  belongs_to :user
  belongs_to :lms_instance
end
