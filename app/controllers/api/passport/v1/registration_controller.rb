module Api
  module Passport
    module V1
      class RegistrationController < BaseController
        # POST /api/passport/v1/register
        def register
          broker_base_url = params[:broker_base_url]
          callback_url = params[:callback_url]
          passport_version = params[:passport_version]
          name = params[:name]

          # PASSPORT_API_VERIFICATION_LOGGING: Log incoming registration parameters
          Rails.logger.debug "[PASSPORT_API_VERIFICATION_LOGGING] Received registration request. " \
            "broker_base_url: #{broker_base_url}, " \
            "callback_url: #{callback_url}, " \
            "passport_version: #{passport_version}, " \
            "name: #{name}"

          # 1. Validation (Whitelist, HTTPS, Domain Matching)
          unless validate_registration!(broker_base_url, callback_url)
            # PASSPORT_API_VERIFICATION_LOGGING: Validation failed
            Rails.logger.debug "[PASSPORT_API_VERIFICATION_LOGGING] Broker registration validation failed. Aborting."
            return
          end

          # 2. Create or Update ExtensionManager
          # PASSPORT_API_VERIFICATION_LOGGING: Resolving ExtensionManager
          manager = ExtensionManager.find_or_initialize_by(broker_base_url: broker_base_url)
          manager.name = name || URI.parse(broker_base_url).host
          
          Rails.logger.debug "[PASSPORT_API_VERIFICATION_LOGGING] ExtensionManager resolved. " \
            "New record?: #{manager.new_record?}, Name: #{manager.name}"

          if manager.save
            # PASSPORT_API_VERIFICATION_LOGGING: Successfully saved ExtensionManager, queueing callback job
            Rails.logger.debug "[PASSPORT_API_VERIFICATION_LOGGING] ExtensionManager ID #{manager.id} saved successfully. " \
              "Queueing PassPortRegistrationJob for callback delivery..."
            
            # 3. Queue Phase 2: Asynchronous Credential Delivery
            PassPortRegistrationJob.new.async.perform(manager.id, callback_url)

            # 4. Return 202 Accepted
            # PASSPORT_API_VERIFICATION_LOGGING: Returning 202 Accepted
            Rails.logger.debug "[PASSPORT_API_VERIFICATION_LOGGING] Returning 202 Accepted status response."
            render json: {
              status: 'Accepted',
              message: 'Credentials will be delivered to the provided callback URL.'
            }, status: :accepted
          else
            # PASSPORT_API_VERIFICATION_LOGGING: ExtensionManager save failed
            Rails.logger.debug "[PASSPORT_API_VERIFICATION_LOGGING] ExtensionManager save failed: #{manager.errors.full_messages.join(', ')}"
            render json: { error: manager.errors.full_messages.join(', ') }, status: :unprocessable_entity
          end
        end
      end
    end
  end
end
