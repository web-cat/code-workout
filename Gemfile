source 'https://rubygems.org'

gem 'rails'
gem 'bootstrap-sass', '~> 3.2.0'
gem 'jquery-rails'
gem 'bootstrap-editable-rails'
gem 'codemirror-rails'
gem 'font-awesome-rails'
gem 'formtastic', '~> 2.3.1'
gem 'formtastic-bootstrap'
gem 'sidekiq'
# gem 'jbuilder', '~> 1.2'
gem 'haml', '>= 3.1.4'
gem 'haml-rails'
gem 'coffee-rails', '~> 4.0.0'
gem 'coffee-script-source'

group :assets do
  gem 'sass-rails'
  gem 'uglifier', '>= 1.3.0'
  gem 'autoprefixer-rails'
end

group :development, :test do
  gem 'sqlite3'
  gem 'rspec-rails'
  gem 'annotate'
  gem 'rails-erd', github: 'voormedia/rails-erd'
end
# These two should be in :development, :test above, but are temporarily
# being added to production too, for db population on the deployed site
# during testing.
gem 'factory_girl_rails'
gem 'faker'

group :test do
  gem 'capybara'
end

group :production, :staging do
  gem 'sqlite3'
  # gem 'mysql2'
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
gem 'cancan', '1.6.9' # 1.6.10 broke shallow routes

gem 'fastercsv'       # CSV reading/writing
gem 'kaminari'        # Auto-paginated views
gem 'remotipart'      # Adds support for remote mulitpart forms (file uploads)
gem 'gravtastic'      # For Gravatar integration
gem 'js-routes'       # Route helpers in Javascript
gem 'awesome_print'   # For debugging/logging output

#gems for rich text editing
gem "bootstrap-wysihtml5-rails"

#gem for improved WHERE querying
gem "squeel"

#for nested forms
gem "cocoon"

# Gems for deployment.
gem 'capistrano'
gem 'capistrano-bundler'
gem 'capistrano-rails'

#for multi-color progress bar
gem 'css3-progress-bar-rails'
