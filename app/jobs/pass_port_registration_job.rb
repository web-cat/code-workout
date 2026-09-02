class PassPortRegistrationJob
  include SuckerPunch::Job
  workers 1

  # -------------------------------------------------------------
  # Phase 2: Send credentials to the broker asynchronously.
  def perform(manager_id, callback_url)
    manager = ExtensionManager.find_by(id: manager_id)
    
    # PASSPORT_API_VERIFICATION_LOGGING: Start of async callback delivery
    Rails.logger.debug "[PASSPORT_API_VERIFICATION_LOGGING] PassPortRegistrationJob started. " \
      "manager_id: #{manager_id}, callback_url: #{callback_url}, " \
      "resolved_manager_present?: #{!manager.nil?}"

    return unless manager && callback_url

    extension_handler_url = Rails.application.routes.url_helpers.api_passport_v1_extension_url(
      host: Rails.application.config.action_mailer.default_url_options[:host] || 'codeworkout.org'
    )

    payload = {
      tool_name: 'CodeWorkout',
      passport_version: '1.0',
      endpoints: {
        extension_handler: extension_handler_url
      },
      requested_properties: PASSPORT_REQUESTED_PROPERTIES,
      credentials: {
        client_id: manager.client_id,
        client_secret: manager.client_secret
      }
    }

    # PASSPORT_API_VERIFICATION_LOGGING: Delivery payload details (securely excluding raw client_secret)
    Rails.logger.debug "[PASSPORT_API_VERIFICATION_LOGGING] Preparing callback POST payload: " \
      "tool_name: 'CodeWorkout', " \
      "passport_version: '1.0', " \
      "extension_handler: #{extension_handler_url}, " \
      "requested_properties: #{PASSPORT_REQUESTED_PROPERTIES}, " \
      "client_id: #{manager.client_id}, " \
      "client_secret_present?: #{manager.client_secret.present?}"

    begin
      # PASSPORT_API_VERIFICATION_LOGGING: Sending POST request
      Rails.logger.debug "[PASSPORT_API_VERIFICATION_LOGGING] Sending callback registration credentials via POST to #{callback_url}..."
      response = RestClient.post(callback_url, payload.to_json, { content_type: :json, accept: :json })
      
      # PASSPORT_API_VERIFICATION_LOGGING: Callback successful
      Rails.logger.debug "[PASSPORT_API_VERIFICATION_LOGGING] Callback registration successfully completed. " \
        "Response status code: #{response.code}"
    rescue => e
      # PASSPORT_API_VERIFICATION_LOGGING: Callback failed
      Rails.logger.debug "[PASSPORT_API_VERIFICATION_LOGGING] Callback registration failed with exception: #{e.message}"
      Rails.logger.error "PassPort Registration Callback Failed for #{callback_url}: #{e.message}"
    end
  end
end
