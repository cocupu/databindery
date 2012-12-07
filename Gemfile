source 'http://rubygems.org'

gem 'rails', '3.2.8'

gem 'json'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.5'
  gem 'coffee-rails', '~> 3.2.2'
  gem 'uglifier', '>= 1.2.3'
  gem 'therubyracer', '~> 0.10.0'# required on linux (ver 0.11.0 wasn't building native extensions)
  gem 'jquery-rails'
  gem 'handlebars_assets'
  gem 'rails-backbone'
  gem 'bootstrap-kaminari-views'
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

group :test, :development do
  gem "rspec-rails"
  gem 'unicorn'  # Use unicorn as the webserver
  gem "factory_girl_rails"
  gem 'jasmine'
  gem 'jasminerice'
  gem 'cocupu', github: 'cocupu/client' # The ruby client 
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
gem "blacklight", '4.0.0'

gem "bootstrap-sass"

gem "unicode", :platforms => [:mri_18, :mri_19]
