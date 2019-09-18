source 'https://rubygems.org'

gem 'rails', '~> 4.2'
gem 'bootstrap-sass-backport', '~> 3.2.0'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'bootstrap-editable-rails'
gem 'codemirror-rails'
gem 'font-awesome-rails'
gem 'formtastic', '~> 3.1'
gem 'formtastic-bootstrap'
gem 'sucker_punch', '~> 1.0'
gem 'haml', '>= 3.1.4'
gem 'haml-rails'
gem 'coffee-rails', '~> 4.0.0'
gem 'coffee-script-source'
gem 'test-unit', '~> 3.0.9'
gem 'nokogiri', '~> 1.10.4'
gem 'csv_shaper'
gem 'andand', github: 'raganwald/andand'
gem 'responders' # Can't move above 1.1 until migrating to rails 4.2+
gem 'friendly_id', '~> 5'
gem 'active_record-acts_as'
gem 'acts_as_list'
gem 'acts-as-taggable-on'
gem 'representable', '~> 2.1'
gem 'redcarpet'
gem 'loofah'
gem 'truncate_html'
gem 'tzinfo' # For timezone support
gem 'active_record_union'
gem 'mysql2', '~> 0.3.20'
gem 'modernizr-rails'
gem 'rubyzip', '>= 1.0.0'

# For JSON support
gem 'rabl'
gem 'oj', '~> 2.16'
gem 'oj_mimic_json'

group :assets do
  gem 'sass-rails'
  gem 'uglifier', '>= 1.3.0'
  gem 'autoprefixer-rails'
end

group :development, :test do
  gem 'thin'
  gem 'byebug'
  gem 'sqlite3', '~> 1.3.0'
  gem 'rspec-rails'
  gem 'annotate'
  gem 'rails-erd', github: 'voormedia/rails-erd'
  gem 'faker'
  # Needed for debugging support in Aptana Studio.  Disabled, since these
  # two gems do not support Ruby 2.0 yet :-(.
  # gem 'ruby-debug-base'
  # gem 'ruby-debug-ide'
  gem 'pry'
  gem 'request-log-analyzer'
end
gem 'factory_bot_rails'
gem 'log_file'

group :test do
  gem 'capybara'
end

group :production, :staging, :deploy  do
  gem 'puma'
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
gem 'cancancan'
gem 'activeadmin'
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
gem 'squeel', '~> 1.2'

#for nested forms
gem 'cocoon'

# For handling converting to booleans
gem 'wannabe_bool'

# Gems for deployment.
group :deploy do
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-rvm'
  gem 'capistrano3-puma', github: 'seuros/capistrano-puma'
end

#for multi-color progress bar
gem 'css3-progress-bar-rails'

gem 'immigrant'
gem 'ims-lti', '~> 1.1.8'
#Gems for OpenPOP support
gem 'rest-client'
