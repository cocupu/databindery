source 'http://rubygems.org'

#gem 'rails', '3.2.6'
gem 'rails', '3.2.7.rc1'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'
# gem 'journey', :git => 'https://github.com/rails/journey.git'
# 
# gem 'active_record_deprecated_finders', :git => 'git://github.com/rails/active_record_deprecated_finders.git'


gem 'json'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.5'
  gem 'coffee-rails', '~> 3.2.2'
  gem 'uglifier', '>= 1.2.3'
  gem 'therubyracer' # required on linux
end

gem 'jquery-rails'
gem 'haml'
gem 'roo', '>=1.10.1'

gem 'carrot'
gem 'amqp'

gem 'pg'
#gem 'activerecord-postgres-hstore'
gem 'activerecord-postgres-hstore', git: 'git://github.com/softa/activerecord-postgres-hstore.git'

gem 'foreigner'

gem 'uuid'


group :test, :development do
  gem "rspec-rails"
  gem 'unicorn'  # Use unicorn as the webserver
end
group :test do
  gem "database_cleaner", ">= 0.7.0"
  gem "factory_girl_rails"
  gem "capybara", ">= 1.1.2"
end

gem "devise"
gem "aws-sdk"
gem "jettywrapper"
gem "rsolr"
gem "cancan"


