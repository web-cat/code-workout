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

          # PASSPORT_API_VERIFICATION_LOGGING: Log incoming headers
          Rails.logger.debug "[PASSPORT_API_VERIFICATION_LOGGING] Verifying signature. Headers - " \
            "X-PassPort-Client-Id: #{client_id}, " \
            "X-PassPort-Signature: #{signature}, " \
            "X-PassPort-Timestamp: #{timestamp}"

          @manager = ExtensionManager.find_by(client_id: client_id)
          
          if @manager.nil? || signature.blank? || timestamp.blank?
            # PASSPORT_API_VERIFICATION_LOGGING: Missing credentials or manager not found
            Rails.logger.debug "[PASSPORT_API_VERIFICATION_LOGGING] Authentication failed: " \
              "manager_nil?: #{@manager.nil?}, signature_blank?: #{signature.blank?}, timestamp_blank?: #{timestamp.blank?}"
            render json: { error: 'Authentication failed' }, status: :unauthorized
            return false
          end

          # PASSPORT_API_VERIFICATION_LOGGING: Resolved ExtensionManager details
          Rails.logger.debug "[PASSPORT_API_VERIFICATION_LOGGING] Resolved ExtensionManager ID: #{@manager.id}, Name: #{@manager.name}"

          # Verify timestamp to prevent replay attacks (5 minute window)
          time_delta = (Time.now.to_i - timestamp.to_i).abs
          if time_delta > 300
            # PASSPORT_API_VERIFICATION_LOGGING: Replay window check failed
            Rails.logger.debug "[PASSPORT_API_VERIFICATION_LOGGING] Request expired. Timestamp time delta is #{time_delta} seconds (max 300s allowed)."
            render json: { error: 'Request expired' }, status: :unauthorized
            return false
          end

          # Reconstruct signature base: method|url|timestamp|body
          body = request.raw_post
          base_string = "#{request.method}|#{request.original_url}|#{timestamp}|#{body}"
          expected_signature = OpenSSL::HMAC.hexdigest('SHA256', @manager.client_secret, base_string)

          # PASSPORT_API_VERIFICATION_LOGGING: Cryptographic details
          Rails.logger.debug "[PASSPORT_API_VERIFICATION_LOGGING] Cryptographic Check - " \
            "Expected: #{expected_signature}, " \
            "Received: #{signature}, " \
            "Base String: '#{base_string}'"

          unless Rack::Utils.secure_compare(expected_signature, signature)
            # PASSPORT_API_VERIFICATION_LOGGING: Signature check failed
            Rails.logger.debug "[PASSPORT_API_VERIFICATION_LOGGING] Cryptographic validation failed: signature mismatch."
            render json: { error: 'Invalid signature' }, status: :unauthorized
            return false
          end
          
          # PASSPORT_API_VERIFICATION_LOGGING: Signature verified
          Rails.logger.debug "[PASSPORT_API_VERIFICATION_LOGGING] Signature verification successful for ExtensionManager #{@manager.name}."
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
        # Validate Phase 1 registration parameters.
        def validate_registration!(broker_base_url, callback_url)
          # PASSPORT_API_VERIFICATION_LOGGING: Start of registration validation
          Rails.logger.debug "[PASSPORT_API_VERIFICATION_LOGGING] Validating registration. " \
            "Broker base: #{broker_base_url}, Callback: #{callback_url}"

          # 1. Whitelist Check
          unless whitelisted?(broker_base_url)
            # PASSPORT_API_VERIFICATION_LOGGING: Whitelist failure
            Rails.logger.debug "[PASSPORT_API_VERIFICATION_LOGGING] Registration failed: Domain '#{broker_base_url}' not whitelisted."
            render json: { error: 'Domain not whitelisted' }, status: :forbidden
            return false
          end

          # 2. HTTPS Enforcement (except localhost)
          unless (broker_base_url.start_with?('https://') || broker_base_url.include?('localhost')) &&
                 (callback_url.start_with?('https://') || callback_url.include?('localhost'))
            # PASSPORT_API_VERIFICATION_LOGGING: HTTPS enforcement failure
            Rails.logger.debug "[PASSPORT_API_VERIFICATION_LOGGING] Registration failed: HTTPS required for registration."
            render json: { error: 'HTTPS required for registration' }, status: :bad_request
            return false
          end

          # 3. Domain Matching
          unless domain_match?(broker_base_url, callback_url)
            # PASSPORT_API_VERIFICATION_LOGGING: Domain mismatch failure
            Rails.logger.debug "[PASSPORT_API_VERIFICATION_LOGGING] Registration failed: Callback URL domain mismatch."
            render json: { error: 'Callback URL domain mismatch' }, status: :bad_request
            return false
          end

          # PASSPORT_API_VERIFICATION_LOGGING: Registration validation successful
          Rails.logger.debug "[PASSPORT_API_VERIFICATION_LOGGING] Registration validation successful."
          true
        end

        # -------------------------------------------------------------
        # Check if two URLs have the same protocol, host, and port.
        def domain_match?(url1, url2)
          u1 = URI.parse(url1)
          u2 = URI.parse(url2)
          u1.scheme == u2.scheme && u1.host == u2.host && u1.port == u2.port
        rescue URI::InvalidURIError
          false
        end

        # -------------------------------------------------------------
        # Verify that the broker_base_url is whitelisted.
        def whitelisted?(broker_base_url)
          host = URI.parse(broker_base_url).host
          PASSPORT_WHITELIST.any? do |pattern|
            if pattern.is_a?(Regexp)
              pattern.match?(host)
            else
              pattern == host
            end
          end
        rescue URI::InvalidURIError
          false
        end
      end
    end
  end
end
