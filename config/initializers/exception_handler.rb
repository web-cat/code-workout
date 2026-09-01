# frozen_string_literal: true

# Filter out unsolicited 4xx client errors (such as bot scans, penetration probes,
# 404 routing errors, and 406 format errors) from being saved to the `errors` table,
# while preserving 500s and internal client errors.

Rails.application.config.to_prepare do
  ExceptionHandler::Exception.class_eval do
    validate :ignore_unsolicited_client_errors

    CLIENT_ERROR_STATUSES = [404, 406].freeze
    CLIENT_ERROR_CLASSES = [
      'ActionController::RoutingError',
      'ActionController::UnknownFormat',
      'AbstractController::ActionNotFound'
    ].freeze

    private

    def ignore_unsolicited_client_errors
      if CLIENT_ERROR_STATUSES.include?(status.to_i) || CLIENT_ERROR_CLASSES.include?(class_name)
        errors.add(:base, 'External or missing referrer on 4xx client error') unless internal_referrer?
      end
    end

    def internal_referrer?
      ref = self[:referrer].presence ||
            (respond_to?(:referer) ? referer : nil) ||
            (request.respond_to?(:referer) ? request.referer : nil)

      return false if ref.blank?

      # Relative URL path on the same host (e.g. "/gym/workouts")
      return true if ref.start_with?('/') && !ref.start_with?('//')

      ref_uri = URI.parse(ref)
      ref_host = ref_uri.host
      return false if ref_host.blank?

      req_host = (request.respond_to?(:host) ? request.host : nil)
      if req_host.blank? && target.present?
        req_host = (URI.parse(target).host rescue nil)
      end

      return false if req_host.blank?
      ref_host.casecmp?(req_host)
    rescue URI::InvalidURIError
      false
    end
  end
end
