source 'http://rubygems.org'

gem 'rails', '3.1.3'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'json'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.1.5'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'
gem 'haml'
gem 'roo', '>=1.10.1'
gem 'delayed_job'
gem 'delayed_job_mongoid'

group :test, :development do
  #gem "rspec-rails", ">= 2.8.0.rc1"
  gem "rspec-rails", "~> 2.7.0"
  gem 'unicorn'  # Use unicorn as the webserver
  gem 'ruby-debug19'
end
group :test do
  gem "mocha"
  gem "database_cleaner", ">= 0.7.0"
  gem "mongoid-rspec", ">= 1.4.4"
  gem "factory_girl_rails", ">= 1.4.0"
  gem "cucumber-rails", ">= 1.2.0"
  gem "capybara", ">= 1.1.2"
end

gem "bson_ext", ">= 1.5.1"
gem "mongoid", ">= 2.3.4"
gem "devise", ">= 1.5.1"
gem "mongoid-paperclip", :require => "mongoid_paperclip"
gem "aws-s3",            :require => "aws/s3"

gem "jettywrapper", ">= 1.2.0"
gem "rsolr"

