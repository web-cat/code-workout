class PassPortRegistrationJob
  include SuckerPunch::Job
  workers 1

  # -------------------------------------------------------------
  # Phase 2: Send credentials to the broker asynchronously.
  def perform(manager_id, callback_url)
    manager = ExtensionManager.find_by(id: manager_id)
    return unless manager && callback_url

    payload = {
      tool_name: 'CodeWorkout',
      passport_version: '1.0',
      endpoints: {
        extension_handler: Rails.application.routes.url_helpers.api_passport_v1_extension_url(
          host: Rails.application.config.action_mailer.default_url_options[:host] || 'codeworkout.org'
        )
      },
      requested_properties: PASSPORT_REQUESTED_PROPERTIES,
      credentials: {
        client_id: manager.client_id,
        client_secret: manager.client_secret
      }
    }

    begin
      RestClient.post(callback_url, payload.to_json, { content_type: :json, accept: :json })
    rescue => e
      Rails.logger.error "PassPort Registration Callback Failed for #{callback_url}: #{e.message}"
    end
  end
end
