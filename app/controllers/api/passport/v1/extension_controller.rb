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

          # 2. Find LMS Instance
          # We normalize the URL by removing protocol and trailing slash for comparison if needed, 
          # but for now we try exact match on the url field.
          lms_instance = LmsInstance.find_by(url: lms_instance_url)
          if lms_instance.nil?
            # Fallback: try matching without protocol if issuer is just a domain
            domain = lms_instance_url.sub(/\Ahttps?:\/\//, '').sub(/\/+\z/, '')
            lms_instance = LmsInstance.where("url LIKE ?", "%#{domain}%").first
          end

          if lms_instance.nil?
            render json: { error: 'LMS Instance not found' }, status: :not_found
            return
          end

          # 3. Find User
          identity = LtiIdentity.find_by(lms_instance: lms_instance, lti_user_id: lti_user_id)
          if identity.nil?
            render json: { error: 'User not found' }, status: :not_found
            return
          end
          user = identity.user

          # 4. Find WorkoutOffering
          # We use the decoupled identifiers from Phase 1
          offering = WorkoutOffering.find_by(
            lms_instance: lms_instance,
            lti_assignment_id: lti_assignment_id
          )
          if offering.nil?
            # Fallback to lms_assignment_id
            offering = WorkoutOffering.find_by(
              lms_instance: lms_instance,
              lms_assignment_id: lti_assignment_id
            )
          end

          if offering.nil?
            render json: { error: 'Assignment not found' }, status: :not_found
            return
          end

          # 5. Check for Conflict (Later date already active)
          existing_ext = StudentExtension.find_by(user: user, workout_offering: offering)
          if existing_ext && existing_ext.hard_deadline && existing_ext.hard_deadline > DateTime.iso8601(new_due_date)
            render json: { error: 'Later extension already active' }, status: :conflict
            return
          end

          # 6. Apply Extension
          # Map new_due_date to both soft and hard deadlines for consistency
          due_dt = DateTime.iso8601(new_due_date)
          StudentExtension.create_or_update!(user, offering, {
            'soft_deadline' => due_dt.strftime('%Q'),
            'hard_deadline' => due_dt.strftime('%Q')
          })

          render json: { message: 'Extension applied successfully' }, status: :ok
        end

        # DELETE /api/passport/v1/extension
        def destroy
          # Identification logic (same as create)
          lms_instance_url = params.dig(:context, :issuer) || params.dig(:context, :lms_instance)
          lti_user_id = params.dig(:user, :lti_user_id)
          lti_assignment_id = params.dig(:resource, :lti_resource_link_id) || params.dig(:resource, :canvas_assignment_id)

          lms_instance = LmsInstance.find_by(url: lms_instance_url)
          identity = LtiIdentity.find_by(lms_instance: lms_instance, lti_user_id: lti_user_id) if lms_instance
          offering = WorkoutOffering.find_by(lms_instance: lms_instance, lti_assignment_id: lti_assignment_id) if lms_instance

          if lms_instance && identity && offering
            extension = StudentExtension.find_by(user: identity.user, workout_offering: offering)
            if extension
              extension.destroy
              render json: { message: 'Extension removed' }, status: :ok
            else
              render json: { error: 'Extension not found' }, status: :not_found
            end
          else
            render json: { error: 'Resource not found' }, status: :not_found
          end
        end
      end
    end
  end
end
