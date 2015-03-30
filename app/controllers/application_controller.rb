require 'application_responder'

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  self.responder = ApplicationResponder
  respond_to :html


  # -------------------------------------------------------------
  unless Rails.application.config.consider_all_requests_local
#    rescue_from Exception,
#      with: lambda { |exception| render_error 500, exception }
#
#    rescue_from ActionController::RoutingError,
#      ActionController::UnknownController,
#      ::AbstractController::ActionNotFound,
#      ActiveRecord::RecordNotFound,
#      with: lambda { |exception| render_error 404, exception }
#
    rescue_from CanCan::AccessDenied,
      with: lambda { |exception| render_error 403, exception }
  end


  # -------------------------------------------------------------
  # Provide authentication for active_admin backend rooted at /admin/...
  def authenticate_admin_user!
    if !current_user ||
      !current_user.global_role.can_edit_system_configuration?
      raise CanCan::AccessDenied
    end
  end


  # -------------------------------------------------------------
  # For use in ExercisesController and other places.  Only intended for
  # Javascript escaping in controller-oriented responsibilities, not view
  # behaviors.
  JHELPER = Class.new.extend(ActionView::Helpers::JavaScriptHelper)
  def escape_javascript(text)
    JHELPER.escape_javascript(text)
  end

end
