source 'http://rubygems.org'

gem "rails", "~> 4.0.1"
gem "activerecord-session_store"
gem 'activerecord-import'
gem 'json'
gem 'angular_rails_csrf'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem "bower-rails", "~> 0.7.0"
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier', '>= 1.2.3'
  #gem 'therubyracer', '~> 0.10.0'# required on linux (ver 0.11.0 wasn't building native extensions)
  gem 'therubyracer'# required on linux
  gem 'handlebars_assets'
  gem 'bootstrap-kaminari-views'
end

gem 'haml'
gem 'roo', "~> 1.12.2"

gem 'google-api-client', '0.4.5', :require =>'google/api_client'

gem 'carrot'
gem 'amqp'
gem "resque", "=1.26.pre.0"
# Need the github version of resque-status to avoid bug where mocha was declared as runtime dependency
gem 'resque-status', github:'quirkey/resque-status', ref: '66f3f35f945859c80a56b4b573325a79b556f243'
gem 'resque-pool'

gem 'pg'

gem 'foreigner'

gem 'uuid'
gem 'kaminari'
gem 'deprecation'


group :test, :development do
  gem "rspec-rails", ">= 2.14.0"
  gem 'unicorn'  # Use unicorn as the webserver
  gem "factory_girl_rails"
  gem 'jasmine'
  gem 'jasminerice', github:"bradphelan/jasminerice", ref:"091349c27343bfa728b8e5745675f9ddbb7d9699"
  gem 'cocupu', github: 'cocupu/databindery-client', ref:"c03ce406659291abf35e9137e5d6c19580ce2c6b" # The ruby client
  # gem 'cocupu', path: '../databindery-client' # The ruby client
  gem "debugger"
end
group :test do
  gem "database_cleaner", ">= 0.7.0"
  gem "capybara", ">= 1.1.2"
end

gem "devise"
gem "aws-sdk"
gem "jettywrapper"
gem "rsolr"
gem "solrizer"
gem "cancan"
gem "blacklight"
