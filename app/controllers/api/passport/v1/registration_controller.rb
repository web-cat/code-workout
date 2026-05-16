module Api
  module Passport
    module V1
      class RegistrationController < BaseController
        # POST /api/passport/v1/register
        def register
          broker_base_url = params[:broker_base_url]
          passport_version = params[:passport_version]

          # 1. Domain Whitelisting Check
          unless whitelisted?(broker_base_url)
            render json: { error: 'Domain not whitelisted' }, status: :forbidden
            return
          end

          # 2. Origin Verification
          return unless verify_origin!(broker_base_url)

          # 3. Create or Update ExtensionManager
          manager = ExtensionManager.find_or_initialize_by(broker_base_url: broker_base_url)
          manager.name = params[:name] || URI.parse(broker_base_url).host
          
          if manager.save
            # 4. Return Credentials and requested properties
            render json: {
              client_id: manager.client_id,
              client_secret: manager.client_secret,
              requested_properties: PASSPORT_REQUESTED_PROPERTIES,
              passport_version: '1.0'
            }, status: :ok
          else
            render json: { error: manager.errors.full_messages.join(', ') }, status: :unprocessable_entity
          end
        end
      end
    end
  end
end
