module Api
  module Passport
    module V1
      class BaseController < ActionController::API
        private

        # -------------------------------------------------------------
        # Verify the HMAC-SHA256 signature of the request.
        def verify_signature!
          client_id = request.headers['X-PassPort-Client-Id']
          signature = request.headers['X-PassPort-Signature']
          timestamp = request.headers['X-PassPort-Timestamp']

          @manager = ExtensionManager.find_by(client_id: client_id)
          
          if @manager.nil? || signature.blank? || timestamp.blank?
            render json: { error: 'Authentication failed' }, status: :unauthorized
            return false
          end

          # Verify timestamp to prevent replay attacks (5 minute window)
          if (Time.now.to_i - timestamp.to_i).abs > 300
            render json: { error: 'Request expired' }, status: :unauthorized
            return false
          end

          # Reconstruct signature base: method|url|timestamp|body
          body = request.raw_post
          base_string = "#{request.method}|#{request.original_url}|#{timestamp}|#{body}"
          expected_signature = OpenSSL::HMAC.hexdigest('SHA256', @manager.client_secret, base_string)

          unless Rack::Utils.secure_compare(expected_signature, signature)
            render json: { error: 'Invalid signature' }, status: :unauthorized
            return false
          end
          true
        end

        # -------------------------------------------------------------
        # Verify that the request origin matches the provided broker_base_url.
        def verify_origin!(broker_base_url)
          # We check the request.base_url which includes protocol and host
          # but excludes path.
          unless request.base_url == broker_base_url
            render json: { error: 'Request origin mismatch' }, status: :forbidden
            return false
          end
          true
        end

        # -------------------------------------------------------------
        # Verify that the broker_base_url is whitelisted.
        def whitelisted?(broker_base_url)
          PASSPORT_WHITELIST.any? do |pattern|
            if pattern.is_a?(Regexp)
              pattern.match?(broker_base_url)
            else
              pattern == broker_base_url
            end
          end
        end
      end
    end
  end
end
