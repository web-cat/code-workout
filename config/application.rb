require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CodeWorkout
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2
    Rails.application.config.active_record.belongs_to_required_by_default = false
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # exception_handler configuration (no longer relies on an initializer)
    config.exception_handler = {
      db: true,
      dev: true
    }
    
    # Timeout for feedback polls (milliseconds)
    # This is an initial value on application startup, but it might change
    config.feedback_timeout = 1700
    config.feedback_timeout_padding = 300

    # Allow iframe embedding?
    config.action_dispatch.default_headers.merge!(
      {'X-Frame-Options' => 'ALLOWALL'})
  end
end
