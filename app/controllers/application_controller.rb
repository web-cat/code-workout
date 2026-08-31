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


  # -------------------------------------------------------------
  def generate_lti_launch_token(lms_instance_id)
    token = (rand(90000000) + 10000000).to_s
    session[:lti_contexts] ||= {}
    session[:lti_contexts][token] = {
      'lms_instance_id' => lms_instance_id,
      'timestamp' => Time.now.to_i
    }
    
    # Keep only the last 2 launches to minimize cookie size
    if session[:lti_contexts].size > 2
      oldest_token = session[:lti_contexts].keys.min_by do |t|
        ctx = session[:lti_contexts][t]
        ctx.is_a?(Hash) ? (ctx['timestamp'] || ctx[:timestamp] || 0) : 0
      end
      session[:lti_contexts].delete(oldest_token)
    end
    
    token
  end


  # -------------------------------------------------------------
  def lti_context_for_token(token)
    return nil if token.blank? || !session[:lti_contexts].is_a?(Hash)
    ctx = session[:lti_contexts][token.to_s] || session[:lti_contexts][token.to_sym]
    ctx.is_a?(Hash) ? ctx.with_indifferent_access : nil
  end

end
