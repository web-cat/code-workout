# frozen_string_literal: true

require 'digest'

module ErrorAggregation
  extend ActiveSupport::Concern

  included do
    belongs_to :user_agent, optional: true

    before_save :aggregate_duplicate_errors
  end

  # Virtual setter to transparently support assigning raw string user agents
  def user_agent=(val)
    if val.is_a?(UserAgent) || val.nil?
      super(val)
    else
      super(UserAgent.find_or_create_by_raw(val))
    end
  end

  def raw_user_agent
    if user_agent.is_a?(UserAgent)
      user_agent.raw_user_agent
    elsif user_agent.present?
      user_agent.to_s
    elsif respond_to?(:request) && request.respond_to?(:user_agent)
      request.user_agent
    end
  end

  def generate_fingerprint
    sanitized_msg = message.to_s.gsub(/0x[0-9a-fA-F]+/, '').strip
    top_trace = trace.to_s.lines.first(3).join

    Digest::SHA256.hexdigest("#{class_name}:#{sanitized_msg}:#{top_trace}")
  end

  private

  def aggregate_duplicate_errors
    self.fingerprint ||= generate_fingerprint
    self.last_seen_at ||= Time.current

    table_class = self.class
    existing = table_class.find_by(fingerprint: fingerprint)
    if existing && existing.id != id
      existing_id = existing.id
      existing_ua_id = user_agent_id || (user_agent.is_a?(UserAgent) ? user_agent.id : nil) || existing.user_agent_id
      new_count = (existing.count || 1) + 1
      now = Time.current
      new_target = target
      new_referrer = referrer
      new_params = params

      # Execute the update in an independent connection so throw :abort rolling back
      # the current record's insert transaction does not roll back our count increment.
      Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do
          rec = table_class.find_by(id: existing_id)
          rec&.update_columns(
            count: new_count,
            last_seen_at: now,
            target: new_target,
            referrer: new_referrer,
            params: new_params,
            user_agent_id: existing_ua_id
          )
        end
      end.join

      throw :abort
    else
      self.count ||= 1
    end
  end
end
