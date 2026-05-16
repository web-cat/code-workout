module Api
  module Passport
    module V1
      class RegistrationController < BaseController
        # POST /api/passport/v1/register
        def register
          broker_base_url = params[:broker_base_url]
          callback_url = params[:callback_url]
          passport_version = params[:passport_version]

          # 1. Validation (Whitelist, HTTPS, Domain Matching)
          return unless validate_registration!(broker_base_url, callback_url)

          # 2. Create or Update ExtensionManager
          manager = ExtensionManager.find_or_initialize_by(broker_base_url: broker_base_url)
          manager.name = params[:name] || URI.parse(broker_base_url).host
          
          if manager.save
            # 3. Queue Phase 2: Asynchronous Credential Delivery
            PassPortRegistrationJob.new.async.perform(manager.id, callback_url)

            # 4. Return 202 Accepted
            render json: {
              status: 'Accepted',
              message: 'Credentials will be delivered to the provided callback URL.'
            }, status: :accepted
          else
            render json: { error: manager.errors.full_messages.join(', ') }, status: :unprocessable_entity
          end
        end
      end
    end
  end
end
