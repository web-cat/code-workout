source 'https://rubygems.org'

gem 'rails', '4.0.0'

gem 'bootstrap-sass'
gem 'jquery-rails'
gem 'codemirror-rails'
gem 'font-awesome-rails'
gem 'formtastic'
gem 'formtastic-bootstrap'
# gem 'jbuilder', '~> 1.2'
gem 'haml', '>= 3.1.4'
gem 'haml-rails'

group :assets do
  gem 'sass-rails', '~> 4.0.0'
  gem 'coffee-rails', '~> 4.0.0'
  gem 'uglifier', '>= 1.3.0'
end

group :development, :test do
  gem 'sqlite3'
  gem 'rspec-rails'
  gem 'annotate'
  gem 'factory_girl_rails'
  gem 'faker'
end

group :test do
  gem 'capybara'
end

group :production, :staging do
  gem 'mysql2'
end

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
  gem 'rails-erd', require: false
end

# Gems for authentication and authorization.
gem 'devise'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'cancan', '1.6.9' # 1.6.10 broke shallow routes
