require 'spec_helper'

describe 'as a signed in user' do

  before do
    @user = FactoryGirl.create :login
    @my_model = FactoryGirl.create(:model, owner: @user.identities.first)
    log_in(@user)
    visit edit_model_path(@my_model) 
  end

  it 'adds fields and associations' do
    fill_in "Field Name", :with=>'Title'
    select "Text Field", :from=>'Field Type'
    fill_in "Code/URI (optional)", :with=>'dc:title'
    check 'Multi-valued'
    click_on 'Create'
    
  end

end



