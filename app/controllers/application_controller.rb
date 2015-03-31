require 'application_responder'

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  self.responder = ApplicationResponder
  respond_to :html


  # -------------------------------------------------------------
  # On access errors, redirect to home page with flash of error message.
  # This is enabled, even for development, since the default error
  # display for CanCan errors doesn't contain any useful additional info.
  rescue_from CanCan::AccessDenied do |exception|
    access_denied(exception)
  end


  # -------------------------------------------------------------
  def access_denied(exception)
    flash[:error] = exception.message.gsub(/this page/, 'that page')
    redirect_to root_url
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
