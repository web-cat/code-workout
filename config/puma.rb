workers 4
threads 8, 8
daemonize

app_dir = File.expand_path('../..', __FILE__)

# Default to production
rails_env = rails_env || ENV['RAILS_ENV'] || "production"
puts "Running in evironment #{rails_env}"
environment rails_env

# Set up socket location
bind "unix://#{app_dir}/tmp/sockets/puma.sock"

# Logging
stdout_redirect "#{app_dir}/log/puma.stdout.log",
  "#{app_dir}/log/puma.stderr.log",
  true

# Set master PID and state locations
pidfile "#{app_dir}/tmp/pids/puma.pid"
state_path "#{app_dir}/tmp/pids/puma.state"
activate_control_app

on_worker_boot do
  ActiveRecord::Base.connection.disconnect! rescue ActiveRecord::ConnectionNotEstablished
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection
  end
end

before_fork do
  ActiveRecord::Base.connection.disconnect! rescue ActiveRecord::ConnectionNotEstablished
end
