require 'spec_helper'

describe 'as a signed in user' do

  before do
    @identity = FactoryGirl.create :identity
    @pool = FactoryGirl.create(:pool, owner: @identity)
    @worksheet = FactoryGirl.create :worksheet
    visit root_path
    fill_in 'top_login_email', :with => @identity.login_credential.email
    fill_in 'top_login_password', :with => @identity.login_credential.password 
    click_button 'Sign in'
    page.should have_link('Log Out', :href=>'/signout')
    visit new_identity_pool_mapping_template_path(@identity.short_name, @pool, :mapping_template=>{:worksheet_id =>@worksheet.id}) 
  end

  it 'creates a mapping' do
    page.should have_selector('table#data')
    fill_in "This file is an example of a(n):", with: "Data Logbook"
    page.should have_content 'You are using Worksheet 1 of 1 worksheet'
    
  end

end


