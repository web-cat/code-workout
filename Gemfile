source 'http://rubygems.org'

gem 'rails'
gem 'bootstrap-sass', '~> 3.2.0'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'bootstrap-editable-rails'
gem 'codemirror-rails'
gem 'font-awesome-rails'
gem 'formtastic', '~> 3.1'
gem 'formtastic-bootstrap'
#gem 'sidekiq'
gem 'sucker_punch', '~> 1.0'
# gem 'jbuilder', '~> 1.2'
gem 'haml', '>= 3.1.4'
gem 'haml-rails'
gem 'test-unit', '~> 3.0.9'
gem 'nokogiri'
gem 'csv_shaper'
gem 'andand', github: 'raganwald/andand'
gem 'foreigner'
gem 'responders', '~> 1.1' # Can't move above 1.1 until migrating to rails 4.2+
gem 'friendly_id', '~> 5'
gem 'active_record-acts_as'
gem 'acts_as_list'
gem 'acts-as-taggable-on'
gem 'representable'
gem 'kramdown'
  # gem 'redcarpet'
gem 'loofah'
gem 'truncate_html',
  github: 'LevoLeague/truncate_html', branch: 'fix/non-breaking-spaces'
gem 'puma'
gem 'tzinfo' # For timezone support

# for CoffeeScript in views and assets:
gem 'coffee-rails', '~> 4.0.0'
gem 'coffee-script-source'
gem 'therubyracer', platforms: :ruby
gem 'therubyrhino', platforms: :jruby

# For JSON support
gem 'rabl'
gem 'json', platforms: :ruby
gem 'json_pure', platforms: :jruby

group :assets do
  gem 'sass-rails'
  gem 'uglifier', '>= 1.3.0'
  gem 'autoprefixer-rails'
end

gem 'mysql2', '= 0.3.15', platforms: :ruby
gem 'activerecord-jdbcmysql-adapter', platforms: :jruby
group :development, :test do
  gem 'sqlite3', platforms: :ruby
  gem 'activerecord-jdbcsqlite3-adapter', platforms: :jruby
  gem 'rspec-rails'
  gem 'annotate'
  gem 'rails-erd', github: 'voormedia/rails-erd'
  gem 'immigrant'
  gem 'faker'
  # Needed for debugging support in Aptana Studio.  Disabled, since these
  # two gems do not support Ruby 2.0 yet :-(.
  # gem 'ruby-debug-base'
  # gem 'ruby-debug-ide'
  gem 'pry'
  gem 'request-log-analyzer'

  # We're using puma, not thin
  # gem 'thin'

  # Not supported on jruby
  # gem 'byebug'
end
gem 'factory_girl_rails'
gem 'log_file'

group :test do
  gem 'capybara'
end

group :production, :staging do
end

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Gems for authentication and authorization.
gem 'devise'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-google-oauth2'
gem 'omniauth-cas'
gem 'ims-lti', '~> 1.1.8'
gem 'cancancan'
gem 'activeadmin', github: 'activeadmin'
gem "active_admin_import" , github: 'activeadmin-plugins/active_admin_import'
gem 'active_skin', github: 'rstgroup/active_skin'
gem 'exception_handler'

gem 'kaminari'        # Auto-paginated views
gem 'remotipart'      # Adds support for remote mulitpart forms (file uploads)
gem 'gravtastic'      # For Gravatar integration
gem 'js-routes'       # Route helpers in Javascript
gem 'awesome_print'   # For debugging/logging output

#gems for rich text editing
gem 'bootstrap-wysihtml5-rails'

#gems for datepicker
gem 'momentjs-rails', '>= 2.9.0'
gem 'bootstrap3-datetimepicker-rails', '~> 4.17.37'

#gem for improved WHERE querying
gem 'squeel'

#for nested forms
gem 'cocoon'

# For handling converting to booleans
gem 'wannabe_bool'

# Gems for deployment.
gem 'capistrano'
gem 'capistrano-bundler'
gem 'capistrano-rails'
gem 'capistrano3-puma', github: 'seuros/capistrano-puma'

#for multi-color progress bar
gem 'css3-progress-bar-rails'
