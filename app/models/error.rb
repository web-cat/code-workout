# == Schema Information
#
# Table name: errors
#
#  id          :integer          not null, primary key
#  usable_type :string(255)
#  usable_id   :integer
#  class_name  :string(255)
#  message     :text(65535)
#  trace       :text(65535)
#  target_url  :text(65535)
#  referer_url :text(65535)
#  params      :text(65535)
#  user_agent  :text(65535)
#  created_at  :datetime
#  updated_at  :datetime
#
# Indexes
#
#  index_errors_on_class_name  (class_name)
#  index_errors_on_created_at  (created_at)
#

# =============================================================================
# Represents an error record for a run-time error experienced on the server.
# This model class is here purely so that run-time errors can be tracked
# in the database for development/debugging purposes.
#
class Error < ActiveRecord::Base
#  belongs_to :usable, polymorphic: true
end
