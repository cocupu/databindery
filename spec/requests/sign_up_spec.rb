require 'spec_helper'

describe 'as a guest on the sign in page' do

  #Browse to the homepage
  before do
    visit root_path
  end

  describe 'with valid credentials' do

    #Fill in the form with the user’s credentials and submit it.
    before do
      fill_in 'name', :with => 'Joe Blow'
      fill_in 'login_credential_email', :with => 'joe@gmail.com'
      fill_in 'login_credential_password', :with => 'password'
      click_button 'Sign Up'
    end

    it 'has a sign out link' do
#puts page.html.inspect
#pp page.html
      page.should have_link('Log Out', :href=>'/signout')
    end
    it 'has a welcome message' do
      page.should have_css('div.alert-message.success', :text=>'Welcome! You have signed up successfully.')
    end

  end
end

