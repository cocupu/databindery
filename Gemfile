source 'http://rubygems.org'

gem 'rails', '3.2.8'

gem 'json'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.5'
  gem 'coffee-rails', '~> 3.2.2'
  gem 'uglifier', '>= 1.2.3'
  gem 'therubyracer' # required on linux
  gem 'jquery-rails'
  gem "bootstrap-sass-rails"
  gem 'handlebars_assets'
  gem 'rails-backbone'
end

gem 'haml'
gem 'roo', github: 'Empact/roo'

gem 'google-api-client', '0.4.5', :require =>'google/api_client'

gem 'carrot'
gem 'amqp'

gem 'pg'

gem 'foreigner'

gem 'uuid'


group :test, :development do
  gem "rspec-rails"
  gem 'unicorn'  # Use unicorn as the webserver
  gem "factory_girl_rails"
  gem 'jasmine'
  gem 'jasminerice'
end
group :test do
  gem "database_cleaner", ">= 0.7.0"
  gem "capybara", ">= 1.1.2"
end

gem "devise"
gem "aws-sdk"
gem "jettywrapper"
gem "rsolr"
gem "cancan"


