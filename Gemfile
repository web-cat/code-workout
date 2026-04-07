source 'https://rubygems.org'

gem 'rails', '~> 5.1'
gem 'sprockets', '< 4.0.0'
gem 'bootstrap-sass', '~> 3.2.0'
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
gem 'coffee-rails', '~> 4.2'
gem 'coffee-script-source'
gem 'test-unit', '~> 3.0.9'
gem 'nokogiri', '~> 1.10.4'
gem 'csv_shaper'
gem 'andand', git: 'https://github.com/raganwald/andand'
gem 'responders' # Can't move above 1.1 until migrating to rails 4.2+
gem 'friendly_id', '~> 5'
gem 'active_record-acts_as'
gem 'acts_as_list'
gem 'acts-as-taggable-on'
gem 'representable', '~> 2.1'
gem 'redcarpet'
gem 'loofah', '>= 2.3.1'
gem 'peml', github: 'CSSPLICE/peml', branch: 'pif'
gem 'truncate_html'
gem 'tzinfo' # For timezone support
gem 'active_record_union'
gem 'dottie', '~> 0.0.3'
gem 'mysql2', '~> 0.4.0'
gem 'modernizr-rails'
gem 'rubyzip', '>= 1.3.0'
gem 'bootsnap' # Added during Rails 5.2 upgrade

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
  gem 'listen'
  gem 'rspec-rails'
  gem 'annotate'
  gem 'rails-erd', git: 'https://github.com/voormedia/rails-erd'
  gem 'faker'
  gem 'pry'
  gem 'request-log-analyzer'
  gem 'capybara', '~> 3.12.0'
end
gem 'factory_bot_rails'
gem 'log_file'

group :test do
end

group :production, :staging, :deploy  do
  gem 'puma', '~> 4.3.5'
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
gem 'exception_handler', '~> 0.8.0.0'

gem 'kaminari', '~> 1.2.1'        # Auto-paginated views
gem 'remotipart'      # Adds support for remote mulitpart forms (file uploads)
gem 'gravtastic'      # For Gravatar integration
gem 'js-routes'       # Route helpers in Javascript
gem 'awesome_print'   # For debugging/logging output

#gems for rich text editing
gem 'bootstrap-wysihtml5-rails'

#gems for datepicker
gem 'momentjs-rails', '>= 2.9.0'
gem 'bootstrap3-datetimepicker-rails', '~> 4.17.37'

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
  gem 'capistrano3-puma', '~> 4.0.0',
      git: 'https://github.com/seuros/capistrano-puma', branch: 'v4.x'
end

#for multi-color progress bar
gem 'css3-progress-bar-rails'

gem 'immigrant'
gem 'ims-lti', '~> 1.1.8'
#Gems for OpenPOP support
gem 'rest-client'

# Gems for cookie updates
gem 'user_agent_parser', '~> 2.7.0'
gem 'rails_same_site_cookie'
gem 'image_hash'

# Gems for resource uploder
gem 'carrierwave', '1.3.2'

gem 'ed25519'
gem 'bcrypt_pbkdf'
