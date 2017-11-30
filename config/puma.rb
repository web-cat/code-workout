# Default to production
rails_env = rails_env || ENV['RAILS_ENV'] || 'production'
environment rails_env

# For MRI, use workers instead of threads for greater parallelism
if rails_env == 'production'
  workers 10
  threads 2, 2
  daemonize
  preload_app!
elsif rails_env == 'staging'
  workers 4
  threads 2, 8
  daemonize
  preload_app!
else
  # development settings are smaller; at least two workers, for SSE
  workers 2
  threads 2, 4
end

app_dir = File.expand_path('../..', __FILE__)

# Set up socket location
bind "unix://#{app_dir}/tmp/sockets/puma.sock"

# Logging
stdout_redirect "#{app_dir}/log/puma.stdout.log",
  "#{app_dir}/log/puma.stderr.log",
  true

puts "Running in evironment #{rails_env}"
puts "Running on platform #{RUBY_PLATFORM}"

# Set master PID and state locations
pidfile "#{app_dir}/tmp/pids/puma.pid"
state_path "#{app_dir}/tmp/pids/puma.state"
activate_control_app

on_worker_boot do
  require 'active_record'
  ActiveRecord::Base.connection.disconnect! rescue ActiveRecord::ConnectionNotEstablished
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection(
      YAML.load_file("#{app_dir}/config/database.yml")[rails_env])
  end
end

before_fork do
  require 'active_record'
  ActiveRecord::Base.connection.disconnect! rescue ActiveRecord::ConnectionNotEstablished
end
