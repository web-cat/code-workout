# frozen_string_literal: true

module ExceptionHandler
  BOTS = %w[
    Baidu Gigabot Googlebot libwww-per lwp-trivial msnbot SiteUptime Slurp
    Wordpress ZIBB ZyBorg Yandex Jyxobot Huaweisymantecspider ApptusBot
  ].freeze

  ATTRS = %i[class_name status message trace target referrer params user_agent].freeze

  CLIENT_ERROR_STATUSES = [404, 406].freeze
  CLIENT_ERROR_CLASSES = [
    'ActionController::RoutingError',
    'ActionController::UnknownFormat',
    'AbstractController::ActionNotFound'
  ].freeze

  class Exception < (ExceptionHandler.config.try(:db) && defined?(ActiveRecord) ? ActiveRecord::Base : Object)
    if ExceptionHandler.config.try(:db)
      def self.table_name
        ExceptionHandler.config.db
      end

      def initialize(attributes = {})
        super
        ATTRS.each do |type|
          self[type] = eval type.to_s
        end
      end
    else
      include ActiveModel::Model
      include ActiveModel::Validations
      extend ActiveModel::Callbacks
      define_model_callbacks :initialize, only: :after

      def initialize(attributes = {})
        super
        run_callbacks :initialize do
        end
      end
    end

    after_initialize ->(e) { ExceptionHandler::ExceptionMailer.new_exception(e).deliver }, if: :email?

    attr_accessor :request, :klass, :exception, :description
    attr_accessor(*ATTRS) unless ExceptionHandler.config.try(:db)

    validates :user_agent, format: { without: Regexp.new(BOTS.join('|'), Regexp::IGNORECASE) }
    validate :ignore_unsolicited_client_errors

    def exception
      request.env['action_dispatch.exception']
    end

    def klass
      exception.class
    end

    def description
      I18n.with_options scope: [:exception_handler], message: message, status: status do |i18n|
        i18n.t response, default: Rack::Utils::HTTP_STATUS_CODES[status]
      end
    end

    def class_name
      exception ? exception.class.name : ''
    end

    def message
      exception ? exception.message : Rack::Utils::HTTP_STATUS_CODES[status]
    end

    def trace
      exception.andand.backtrace ? exception.backtrace.join("\n") : ''
    end

    def target
      request.url
    end

    # Support both referer and referrer
    def referer
      request.referer
    end

    def referrer
      request.referer
    end

    def params
      request.params.inspect
    end

    def user_agent
      request.user_agent
    end

    def status
      exception ? ActionDispatch::ExceptionWrapper.new(request.env, exception).try(:status_code) : request.env['PATH_INFO'][1..-1].to_i
    end

    def response
      ActionDispatch::ExceptionWrapper.rescue_responses[class_name]
    end

    private

    def email?
      ExceptionHandler.config.try(:email).try(:is_a?, String) && ExceptionHandler.config.options(status, :notification) != false
    end

    def ignore_unsolicited_client_errors
      if CLIENT_ERROR_STATUSES.include?(status.to_i) || CLIENT_ERROR_CLASSES.include?(class_name)
        errors.add(:base, 'External or missing referrer on 4xx client error') unless internal_referrer?
      end
    end

    def internal_referrer?
      ref = referrer.presence || referer.presence || (request.respond_to?(:referer) ? request.referer : nil)
      return false if ref.blank?

      # Relative URL path on the same host (e.g. "/gym/workouts")
      return true if ref.start_with?('/') && !ref.start_with?('//')

      ref_uri = URI.parse(ref)
      ref_host = ref_uri.host
      return false if ref_host.blank?

      req_host = (request.respond_to?(:host) ? request.host : nil)
      if req_host.blank? && target.present?
        req_host = (URI.parse(target).host rescue nil)
      end

      return false if req_host.blank?
      ref_host.casecmp?(req_host)
    rescue URI::InvalidURIError
      false
    end
  end
end
