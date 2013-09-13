# Load the Rails application.
require File.expand_path('../application', __FILE__)
require 'rails_extensions'

# Generate non-pretty-printed HTML even in development (it's faster, and
# with tools like Firebug and the Webkit inspector, we don't need to look
# directly at the source)
Haml::Template.options[:ugly] = true

# Initialize the Rails application.
CodeWorkout::Application.initialize!
