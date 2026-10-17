# frozen_string_literal: true

require 'digest'

class AddFingerprintAndCountToErrors < ActiveRecord::Migration[5.2]
  def up
    add_column :errors, :fingerprint, :string, limit: 64 unless column_exists?(:errors, :fingerprint)
    add_column :errors, :count, :integer, default: 1, null: false unless column_exists?(:errors, :count)
    add_column :errors, :last_seen_at, :datetime unless column_exists?(:errors, :last_seen_at)

    add_index :errors, :fingerprint unless index_exists?(:errors, :fingerprint)
    add_index :errors, :count unless index_exists?(:errors, :count)

    # Temporary model to perform data migration without invoking application callbacks
    error_model = Class.new(ActiveRecord::Base) do
      self.table_name = 'errors'
    end

    # Step 1: Compute and assign fingerprint and initial last_seen_at for all records
    error_model.where(fingerprint: nil).find_each(batch_size: 1000) do |err|
      sanitized_msg = err.message.to_s.gsub(/0x[0-9a-fA-F]+/, '').strip
      top_trace = err.trace.to_s.lines.first(3).join
      fp = Digest::SHA256.hexdigest("#{err.class_name}:#{sanitized_msg}:#{top_trace}")
      seen_time = err.updated_at || err.created_at || Time.current

      err.update_columns(
        fingerprint: fp,
        last_seen_at: seen_time
      )
    end

    # Step 2: Deduplicate any records sharing the same fingerprint while retaining latest context
    duplicate_fps = error_model.group(:fingerprint).having('count(*) > 1').pluck(:fingerprint)
    has_duplicates = duplicate_fps.any?

    duplicate_fps.each do |fp|
      group = error_model.where(fingerprint: fp).order(:id).to_a
      next if group.size <= 1

      # The earliest record serves as the primary to preserve first_seen (created_at)
      primary = group.first
      # The most recent record contains the latest request context
      latest = group.last

      total_count = group.sum { |r| (r.count.to_i > 0) ? r.count.to_i : 1 }
      latest_time = group.map { |r| r.last_seen_at || r.updated_at || r.created_at }.compact.max || Time.current
      latest_ua_id = group.map(&:user_agent_id).compact.last || primary.user_agent_id

      primary.update_columns(
        count: total_count,
        last_seen_at: latest_time,
        target: latest.target.presence || primary.target,
        referrer: latest.referrer.presence || primary.referrer,
        params: latest.params.presence || primary.params,
        user_agent_id: latest_ua_id
      )

      duplicate_ids = group[1..-1].map(&:id)
      error_model.where(id: duplicate_ids).delete_all
    end

    # Step 3: Physically compact and defragment table if duplicate rows were removed
    if has_duplicates && connection.adapter_name =~ /mysql|mariadb/i
      connection.execute('OPTIMIZE TABLE errors')
    end
  end

  def down
    remove_index :errors, :count if index_exists?(:errors, :count)
    remove_index :errors, :fingerprint if index_exists?(:errors, :fingerprint)

    remove_column :errors, :last_seen_at if column_exists?(:errors, :last_seen_at)
    remove_column :errors, :count if column_exists?(:errors, :count)
    remove_column :errors, :fingerprint if column_exists?(:errors, :fingerprint)
  end
end
