class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception

#  # -------------------------------------------------------------
#  unless Rails.application.config.consider_all_requests_local
#    rescue_from Exception,
#      with: lambda { |exception| render_error 500, exception }
#
#    rescue_from ActionController::RoutingError,
#      ActionController::UnknownController,
#      ::AbstractController::ActionNotFound,
#      ActiveRecord::RecordNotFound,
#      with: lambda { |exception| render_error 404, exception }
#
#    rescue_from CanCan::AccessDenied,
#      with: lambda { |exception| render_error 403, exception }
#  end
#
#  protect_from_forgery

end
