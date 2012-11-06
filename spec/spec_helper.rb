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


RSpec.configure do |config|

  config.include Devise::TestHelpers, :type => :controller
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  config.use_transactional_fixtures = true


  # Drop all columns before the test run.
  config.before(:all) do
    Bindery.clear_index 
  end
end


def log_in(user)
    visit root_path
    fill_in 'top_login_email', :with => user.email
    fill_in 'top_login_password', :with => user.password 
    click_button 'Sign in'
    page.should have_link('Log Out', :href=>'/signout')
end

