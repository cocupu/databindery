require 'spec_helper'

describe 'as a guest on the sign in page' do

  #Browse to the homepage
  before do
    visit root_path
  end

  #Fill in the form with the user’s credentials and submit it.
  it "should be able to sign up" do
    fill_in 'user_identities_attributes_0_short_name', :with => 'Joe_Blow'
    fill_in 'user_email', :with => 'joe@example.com'
    fill_in 'user_password', :with => 'password'
    click_button 'Sign Up'
    page.should have_link('Log Out', :href=>'/signout')
    page.should have_css('div.alert.alert-success', :text=>'Welcome! You have signed up successfully.')
  end

end

