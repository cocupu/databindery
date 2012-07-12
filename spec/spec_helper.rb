# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'capybara/rspec'
require 'capybara/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

require 'ripple/test_server'



RSpec.configure do |config|



  config.before(:suite) { Ripple::TestServer.setup }
  config.after(:each) { Ripple::TestServer.clear }


  config.mock_with :mocha
  config.include Devise::TestHelpers, :type => :controller

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Drop all columns before the test run.
  config.before(:all) do
    Cocupu.clear_index 
  end
  config.before(:each) do
    [ModelInstance, Model, JobLogItem].each do |collection|
      collection.destroy_all
    end
  end
end


