# == Schema Information
#
# Table name: errors
#
#  id          :bigint           not null, primary key
#  class_name  :text(65535)
#  message     :text(65535)
#  params      :text(65535)
#  referrer    :text(65535)
#  status      :text(65535)
#  target      :text(65535)
#  trace       :text(65535)
#  usable_type :string(255)
#  user_agent  :text(65535)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  usable_id   :integer
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
class Error < ApplicationRecord
#  belongs_to :usable, polymorphic: true
  belongs_to :user_agent, optional: true

  # Virtual setter to transparently support assigning raw string user agents
  def user_agent=(val)
    if val.is_a?(UserAgent) || val.nil?
      super(val)
    else
      super(UserAgent.find_or_create_by_raw(val))
    end
  end

  def raw_user_agent
    user_agent&.raw_user_agent
  end
end
