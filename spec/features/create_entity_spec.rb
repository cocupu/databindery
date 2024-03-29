require 'spec_helper'

describe 'as a signed in user' do

  before do
    @identity = FactoryGirl.create :identity
    @my_model = FactoryGirl.create(:model, owner: @identity)
    @associated_model = FactoryGirl.create(:model, owner: @identity)
    log_in(@identity.login_credential)
    visit edit_model_path(@my_model) 
  end

  it 'should allow us to create a new entity' do
    pending "Need to do this in backbone.js"
    within(".subnav #menu#{@my_model.id}.dropdown .dropdown-menu") do
      click_link("Create New")
    end

    page.should have_selector("h1", :text=>"New #{@my_model.name}")

    fill_in "Description", :with=>'Test Desc'
    click_on 'Create Entity'

    page.should have_selector(".alert-success", :text=>"#{@my_model.name} created")
    page.should have_selector("#node_data_description[value='Test Desc']")

  end

end



