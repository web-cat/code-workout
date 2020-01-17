require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module CodeWorkout
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.assets.precompile += [
      Proc.new { |filename, path|
        path =~ /app\/assets/ &&
          path !~ /bootstrap-social/ &&
          path !~ /active_admin/ &&
          %w(.js .css).include?(File.extname(filename))
      }
    ]

    # other kinds of assets
    config.assets.precompile += %w(*.png *.jpg *.jpeg *.gif *.mustache.html)

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/lib)

    # Timeout for feedback polls (milliseconds)
    # This is an initial value on application startup, but it might change
    config.feedback_timeout = 1700
    config.feedback_timeout_padding = 300

    config.active_record.raise_in_transactional_callbacks = true
  end
end
