CodeWorkout::Application.configure do
  # Settings specified here will take precedence over those in
  # config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # For SSEs
  config.preload_frameworks = true
  config.allow_concurrency = true

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_url_options = { :host => '192.168.33.20:3000' }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: 'smtp.gmail.com',
    port: 587,
    domain: 'vt.edu',
    authentication: 'plain',
    enable_starttls_auto: true,
    user_name: ENV['GMAIL_USERNAME'],
    password: ENV['GMAIL_PASSWORD']
  }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  # config.assets.compile = false

  # Generate digests for assets URLs.
  # config.assets.digest = true


  config.assets.initialize_on_precompile = true

  config.middleware.use LogFile::Display
  config.log_level = :info
  config.log_formatter = proc do |severity, datetime, progname, msg|
    if severity == 'DEBUG' && msg.blank?
      ''
    else
      case severity
      when 'DEBUG'
        severity_colored = "\033[36;40m[DEBUG]\033[0m" # cyan
      when 'INFO'
        severity_colored = "\033[32;40m[INFO]\033[0m" # green
      when 'WARN'
        severity_colored = "\033[35;40m[WARNING]\033[0m" # magenta
      when 'ERROR'
        severity_colored = "\033[31;40m[ERROR]\033[0m" # red
      when 'FATAL'
        severity_colored = "\033[7;31;40m[FATAL]\033[0m" # black, red bg
      else
        severity_colored = "[#{severity}]" # none
      end
      "%s %s %s\n" % [
        datetime.strftime('%Y-%m-%d %H:%M:%S'),
        severity_colored,
        String === msg ? msg : msg.inspect
        ]
    end
  end
end
