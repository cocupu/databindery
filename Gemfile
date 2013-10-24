source 'http://rubygems.org'

gem 'rails', '3.2.11'

gem 'json'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem "bootstrap-sass"
  gem 'coffee-rails'
  gem 'uglifier', '>= 1.2.3'
  gem 'therubyracer', '~> 0.10.0'# required on linux (ver 0.11.0 wasn't building native extensions)
  gem 'jquery-rails'
  gem 'jquery-datatables-rails', github: 'rweng/jquery-datatables-rails'
  gem 'jquery-ui-rails'
  gem 'handlebars_assets'
  gem 'rails-backbone'
  gem 'angularjs-rails', '~>1.0.8'
  gem 'bootstrap-kaminari-views'
  gem 'haml_assets'
end

gem 'haml'
gem 'roo', github: 'Empact/roo'

gem 'google-api-client', '0.4.5', :require =>'google/api_client'

gem 'carrot'
gem 'amqp'

gem 'pg'

gem 'foreigner'

gem 'uuid'
gem 'strong_parameters'
gem 'kaminari'
gem 's3_direct_upload'


group :test, :development do
  gem "rspec-rails"
  gem 'unicorn'  # Use unicorn as the webserver
  gem "factory_girl_rails"
  gem 'jasmine'
  gem 'jasminerice'
  gem 'cocupu', github: 'cocupu/client', ref:"a988936bb0b7743687ab63868440df20ef19b1e3" # The ruby client
  #gem 'cocupu', path: '../databindery-client' # The ruby client
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
gem "cancan"
gem "blacklight"
