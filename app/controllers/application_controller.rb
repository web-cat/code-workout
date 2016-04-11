require 'application_responder'
require 'loofah_render'

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  # protect_from_forgery with: :null_session

  skip_before_action :verify_authenticity_token

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


  # -------------------------------------------------------------
  # Some pages use the flash to transfer
  def params_with_flash
    params.merge(flash.
      select { |k, v| k.ends_with?('_id') && !params.has_key?(k) })
  end


  # -------------------------------------------------------------
  helper_method :markdown
  def markdown(text)
    markdown = Redcarpet::Markdown.new(
      LoofahRender.new(
        safe_links_only: true, xhtml: true),
      no_intra_emphasis: true,
      tables: true,
      fenced_code_blocks: true,
      autolink: true,
      strikethrough: true,
      lax_spacing: true).render(text)
  end

  def allow_iframe
    response.headers.except! 'X-Frame-Options'
  end

end
