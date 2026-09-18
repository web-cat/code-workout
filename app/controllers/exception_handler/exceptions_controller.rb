module ExceptionHandler
  class ExceptionsController < ApplicationController

    # => Response
    respond_to :html, :js, :json, :xml

    # => CSRF
    protect_from_forgery

    # => Devise
    skip_before_action :authenticate_user!, raise: false

    ##################################
    ##################################

    # Intercept InvalidAuthenticityToken before saving to database
    before_action :handle_invalid_authenticity_token, only: [:show]

    # => Definitions
    # => Exception model (tied to DB)
    before_action { |e| @exception = ExceptionHandler::Exception.new request: e.request }
    before_action { @exception.save if @exception.valid? && ExceptionHandler.config.try(:db) }

    # => Response format (required for non-standard formats (.css / .gz etc))
    before_action { |e| e.request.format = :html unless self.class.respond_to.include? e.request.format }

    # => Routes
    helper Rails.application.routes.url_helpers

    # => Layout
    layout :layout

    ####################
    #     Actions      #
    ####################

    def show
      respond_with @exception, status: @exception.status
    end

    private

    def handle_invalid_authenticity_token
      exception = request.env['action_dispatch.exception']
      if exception.is_a?(ActionController::InvalidAuthenticityToken)
        if request.xhr? || request.format.json?
          render json: { error: 'Your session has expired. Please try again.' }, status: :unprocessable_entity
        else
          flash[:alert] = 'Your session has expired. Please try signing in again.'
          redirect_to root_path
        end
      end
    end

    def layout(option = ExceptionHandler.config.options(@exception.andand.status, :layout))
      (option.present? || option.nil?) ? option : 'exception'
    end

  end
end
