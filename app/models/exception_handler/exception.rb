# frozen_string_literal: true

require 'ipaddr'

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

  IGNORED_ROUTING_PREFIXES = %w[
    /api/v1/
  ].freeze

  IGNORED_ROUTING_PATTERNS = [
    # API endpoints
    %r{\A/api/v1/},

    # PHP scripts (including path-info like /app_dev.php/..., backups like .php.bak, and editor backups like .php~)
    %r{\.(?:php\d*|phtml)(?:\.[\w~]+|~|/|$)}i,

    # WordPress & common CMS probes
    %r{(?:^|/)(?:wp-(?:admin|content|includes|json|login|config|cron)|xmlrpc|wordpress(?:/|$))}i,

    # Common web shells / DB admin tools
    %r{(?:^|/)(?:phpmyadmin|pma|_profiler)\b}i,

    # Hidden environment/source control files and configuration backups
    %r{/\.(?:git|env|aws|ssh)\b}i,
    %r{\.(?:ya?ml|json|tfstate|conf|ini|sql)(?:\.(?:bak|old|save|swp|copy|orig|tmp|\d+)|~)\z}i
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
        if direct_ip_request?
          errors.add(:base, 'Direct numeric IP scan probe')
        elsif ignored_routing_path?
          errors.add(:base, 'Ignored third-party or API routing error')
        elsif !internal_referrer?
          errors.add(:base, 'External or missing referrer on 4xx client error')
        end
      end
    end

    def direct_ip_request?
      req_host = (request.respond_to?(:host) ? request.host : nil)
      req_host = (URI.parse(target).host rescue nil) if req_host.blank? && target.present?
      return true if numeric_ip?(req_host)

      ref = referrer.presence || referer.presence || (request.respond_to?(:referer) ? request.referer : nil)
      if ref.present? && !ref.start_with?('/')
        ref_host = (URI.parse(ref).host rescue nil)
        return true if numeric_ip?(ref_host)
      end

      false
    end

    def numeric_ip?(host)
      return false if host.blank?

      clean_host = host.to_s.strip
      if clean_host.count(':') > 1
        # IPv6 address: only strip port if formatted as [ip]:port
        if clean_host.start_with?('[') && clean_host.include?(']')
          clean_host = clean_host[1..clean_host.index(']') - 1]
        end
      else
        # IPv4 or hostname: strip :port
        clean_host = clean_host.sub(/:\d+\z/, '')
      end

      return false unless clean_host.include?('.') || clean_host.include?(':')

      ip = IPAddr.new(clean_host)
      ip.ipv4? || ip.ipv6?
    rescue StandardError
      false
    end

    def ignored_routing_path?
      candidate_paths = []
      candidate_paths << request.path if request.respond_to?(:path) && request.path.present?
      candidate_paths << request.fullpath if request.respond_to?(:fullpath) && request.fullpath.present?
      candidate_paths << request.original_fullpath if request.respond_to?(:original_fullpath) && request.original_fullpath.present?

      if target.present?
        target_path = (URI.parse(target).path rescue nil)
        candidate_paths << target_path if target_path.present?
      end

      if message.present? && message =~ /No route matches \[[A-Z]+\] ["']([^"']+)["']/i
        candidate_paths << $1
      end

      candidate_paths = candidate_paths.compact.map { |p| p.to_s.split('?').first }.reject do |p|
        p.blank? || p == '/404' || p == '/406' || p == '/500'
      end.uniq

      return true if candidate_paths.any? { |path| ignored_path_match?(path) }

      if message.present?
        return true if IGNORED_ROUTING_PREFIXES.any? { |prefix| message.include?("\"#{prefix}") || message.include?(" '#{prefix}") || message.include?(prefix) }
        return true if IGNORED_ROUTING_PATTERNS.any? { |pattern| pattern.is_a?(Regexp) ? pattern.match?(message) : message.include?(pattern) }
      end

      false
    rescue StandardError
      false
    end

    def ignored_path_match?(path)
      IGNORED_ROUTING_PREFIXES.any? { |prefix| path.start_with?(prefix) } ||
        IGNORED_ROUTING_PATTERNS.any? { |pattern| pattern.is_a?(Regexp) ? pattern.match?(path) : path.start_with?(pattern) }
    end

    def internal_referrer?
      req_host = (request.respond_to?(:host) ? request.host : nil)
      req_host = (URI.parse(target).host rescue nil) if req_host.blank? && target.present?
      return false if req_host.blank? || numeric_ip?(req_host)

      ref = referrer.presence || referer.presence || (request.respond_to?(:referer) ? request.referer : nil)
      return false if ref.blank?

      # Relative URL path on the same host (e.g. "/gym/workouts")
      return true if ref.start_with?('/') && !ref.start_with?('//')

      ref_uri = URI.parse(ref)
      ref_host = ref_uri.host
      return false if ref_host.blank? || numeric_ip?(ref_host)

      ref_host.casecmp?(req_host)
    rescue URI::InvalidURIError
      false
    end
  end
end
