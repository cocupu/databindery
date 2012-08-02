source 'http://rubygems.org'

gem 'rails', '3.2.8.rc1'

gem 'json'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.5'
  gem 'coffee-rails', '~> 3.2.2'
  gem 'uglifier', '>= 1.2.3'
  gem 'therubyracer' # required on linux
  gem "bootstrap-sass-rails"
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
  gem "factory_girl_rails"
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


