module Api
  module Passport
    module V1
      class ExtensionController < BaseController
        before_action :verify_signature!

        # POST /api/passport/v1/extension
        def create
          # 1. Extract context
          lms_instance_url = params.dig(:context, :issuer) || params.dig(:context, :lms_instance)
          lti_user_id = params.dig(:user, :lti_user_id)
          lti_assignment_id = params.dig(:resource, :lti_resource_link_id) || params.dig(:resource, :canvas_assignment_id)
          new_due_date = params.dig(:extension, :new_due_date)

          # PASSPORT_API_VERIFICATION_LOGGING: Log incoming request context
          Rails.logger.debug "[PASSPORT_API_VERIFICATION_LOGGING] Received extension apply request. Context - " \
            "lms_instance_url: #{lms_instance_url}, " \
            "lti_user_id: #{lti_user_id}, " \
            "lti_assignment_id: #{lti_assignment_id}, " \
            "new_due_date: #{new_due_date}"

          # 2. Find LMS Instance
          # We normalize the URL by removing protocol and trailing slash for comparison if needed, 
          # but for now we try exact match on the url field.
          lms_instance = LmsInstance.find_by(url: lms_instance_url)
          if lms_instance.nil?
            # PASSPORT_API_VERIFICATION_LOGGING: URL matching fallback
            domain = lms_instance_url.sub(/\Ahttps?:\/\//, '').sub(/\/+\z/, '')
            Rails.logger.debug "[PASSPORT_API_VERIFICATION_LOGGING] Exact LMS Instance match not found for url '#{lms_instance_url}'. Falling back to domain LIKE search with '#{domain}'."
            lms_instance = LmsInstance.where("url LIKE ?", "%#{domain}%").first
          end

          if lms_instance.nil?
            # PASSPORT_API_VERIFICATION_LOGGING: LMS Instance resolution failed
            Rails.logger.debug "[PASSPORT_API_VERIFICATION_LOGGING] Extension apply failed: LMS Instance not found."
            render json: { error: 'LMS Instance not found' }, status: :not_found
            return
          end

          # PASSPORT_API_VERIFICATION_LOGGING: Resolved LMS Instance details
          Rails.logger.debug "[PASSPORT_API_VERIFICATION_LOGGING] Resolved LMS Instance ID: #{lms_instance.id}, URL: #{lms_instance.url}"

          # 3. Find User
          identity = LtiIdentity.find_by(lms_instance: lms_instance, lti_user_id: lti_user_id)
          if identity.nil?
            # PASSPORT_API_VERIFICATION_LOGGING: User resolution failed
            Rails.logger.debug "[PASSPORT_API_VERIFICATION_LOGGING] Extension apply failed: User not found via LtiIdentity (lti_user_id: #{lti_user_id})."
            render json: { error: 'User not found' }, status: :not_found
            return
          end
          user = identity.user

          # PASSPORT_API_VERIFICATION_LOGGING: Resolved User details
          Rails.logger.debug "[PASSPORT_API_VERIFICATION_LOGGING] Resolved User ID: #{user.id}, Username/Email: #{user.email || user.username}"

          # 4. Find WorkoutOffering
          # We use the decoupled identifiers from Phase 1
          offering = WorkoutOffering.find_by(
            lms_instance: lms_instance,
            lti_assignment_id: lti_assignment_id
          )
          if offering.nil?
            # PASSPORT_API_VERIFICATION_LOGGING: Decoupled lms_assignment_id fallback lookup
            Rails.logger.debug "[PASSPORT_API_VERIFICATION_LOGGING] WorkoutOffering not resolved via lti_assignment_id '#{lti_assignment_id}'. Falling back to lms_assignment_id lookup."
            offering = WorkoutOffering.find_by(
              lms_instance: lms_instance,
              lms_assignment_id: lti_assignment_id
            )
          end

          if offering.nil?
            # PASSPORT_API_VERIFICATION_LOGGING: WorkoutOffering resolution failed
            Rails.logger.debug "[PASSPORT_API_VERIFICATION_LOGGING] Extension apply failed: WorkoutOffering not found."
            render json: { error: 'Assignment not found' }, status: :not_found
            return
          end

          # PASSPORT_API_VERIFICATION_LOGGING: Resolved WorkoutOffering details
          Rails.logger.debug "[PASSPORT_API_VERIFICATION_LOGGING] Resolved WorkoutOffering ID: #{offering.id}, Workout: #{offering.workout.name}"

          # 5. Check for Conflict (Later date already active)
          existing_ext = StudentExtension.find_by(user: user, workout_offering: offering)
          if existing_ext && existing_ext.hard_deadline && existing_ext.hard_deadline > DateTime.iso8601(new_due_date)
            # PASSPORT_API_VERIFICATION_LOGGING: Conflict detected
            Rails.logger.debug "[PASSPORT_API_VERIFICATION_LOGGING] Extension apply aborted due to conflict: " \
              "An existing extension has a later hard deadline (#{existing_ext.hard_deadline}) than requested (#{new_due_date})."
            render json: { error: 'Later extension already active' }, status: :conflict
            return
          end

          # 6. Apply Extension
          # Map new_due_date to both soft and hard deadlines for consistency
          due_dt = DateTime.iso8601(new_due_date)
          
          # PASSPORT_API_VERIFICATION_LOGGING: Applying extension
          Rails.logger.debug "[PASSPORT_API_VERIFICATION_LOGGING] Applying extension: user_id: #{user.id}, " \
            "workout_offering_id: #{offering.id}, due_dt: #{due_dt}"
          
          StudentExtension.create_or_update!(user, offering, {
            'soft_deadline' => due_dt.strftime('%Q'),
            'hard_deadline' => due_dt.strftime('%Q')
          })

          # PASSPORT_API_VERIFICATION_LOGGING: Extension applied successfully
          Rails.logger.debug "[PASSPORT_API_VERIFICATION_LOGGING] Extension applied successfully."
          render json: { message: 'Extension applied successfully' }, status: :ok
        end

        # DELETE /api/passport/v1/extension
        def destroy
          # Identification logic (same as create)
          lms_instance_url = params.dig(:context, :issuer) || params.dig(:context, :lms_instance)
          lti_user_id = params.dig(:user, :lti_user_id)
          lti_assignment_id = params.dig(:resource, :lti_resource_link_id) || params.dig(:resource, :canvas_assignment_id)

          # PASSPORT_API_VERIFICATION_LOGGING: Log incoming delete request context
          Rails.logger.debug "[PASSPORT_API_VERIFICATION_LOGGING] Received extension removal request. Context - " \
            "lms_instance_url: #{lms_instance_url}, " \
            "lti_user_id: #{lti_user_id}, " \
            "lti_assignment_id: #{lti_assignment_id}"

          lms_instance = LmsInstance.find_by(url: lms_instance_url)
          identity = LtiIdentity.find_by(lms_instance: lms_instance, lti_user_id: lti_user_id) if lms_instance
          offering = WorkoutOffering.find_by(lms_instance: lms_instance, lti_assignment_id: lti_assignment_id) if lms_instance

          # PASSPORT_API_VERIFICATION_LOGGING: Log lookup resolutions
          Rails.logger.debug "[PASSPORT_API_VERIFICATION_LOGGING] Resource resolutions - " \
            "lms_instance_resolved?: #{!lms_instance.nil?}, " \
            "user_identity_resolved?: #{!identity.nil?}, " \
            "offering_resolved?: #{!offering.nil?}"

          if lms_instance && identity && offering
            extension = StudentExtension.find_by(user: identity.user, workout_offering: offering)
            if extension
              # PASSPORT_API_VERIFICATION_LOGGING: Removing extension
              Rails.logger.debug "[PASSPORT_API_VERIFICATION_LOGGING] Extension ID #{extension.id} found. Deleting record..."
              extension.destroy
              
              # PASSPORT_API_VERIFICATION_LOGGING: Deletion successful
              Rails.logger.debug "[PASSPORT_API_VERIFICATION_LOGGING] Extension successfully deleted."
              render json: { message: 'Extension removed' }, status: :ok
            else
              # PASSPORT_API_VERIFICATION_LOGGING: Extension not found
              Rails.logger.debug "[PASSPORT_API_VERIFICATION_LOGGING] Extension removal aborted: StudentExtension not found."
              render json: { error: 'Extension not found' }, status: :not_found
            end
          else
            # PASSPORT_API_VERIFICATION_LOGGING: Resolution failed
            Rails.logger.debug "[PASSPORT_API_VERIFICATION_LOGGING] Extension removal aborted: Issuer/User/Assignment resource not found."
            render json: { error: 'Resource not found' }, status: :not_found
          end
        end
      end
    end
  end
end
