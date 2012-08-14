require 'spec_helper'

describe 'as a signed in user' do

  before do
    @user = FactoryGirl.create :login
    @my_model = FactoryGirl.create(:model, owner: @user.identities.first)
    @associated_model = FactoryGirl.create(:model, owner: @user.identities.first)
    log_in(@user)
    visit edit_model_path(@my_model) 
  end

  it 'adds fields and associations' do
    within("#add_field") do
      
      fill_in "Field Name", :with=>'Title'
      select "Text Field", :from=>'Field Type'
      fill_in "Code/URI (optional)", :with=>'dc:title'
      check 'Multi-valued'
      click_on 'Create'
    end

    page.should have_selector '#fields tbody tr:first td:nth-child(2)', :text=>'Title'

    ### Add association

    within("#add_association") do
      select "Has Many", :from => 'Type'
      fill_in "Association Name", :with=>"talks"
      select @associated_model.name, :from => "Points to"
      click_on 'Create'
    end
    
    page.should have_selector '#fields tbody tr:first td:nth-child(2)', :text=>'Title'
  end

end



