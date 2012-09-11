require 'spec_helper'

describe ChattelsController do

  it "should have routes" do
    {:get=>'/chattels/new'}.should route_to(:controller=>'chattels', :action=>'new')
    {:post=>'/chattels'}.should route_to(:controller=>'chattels', :action=>'create')
    {:get=>'/chattels/3/describe'}.should route_to(:controller=>'chattels', :action=>'describe', :id=>'3')
  end

  describe "new" do
    before do
      cred = FactoryGirl.create :login_credential
      sign_in cred
    end
    render_views
    let(:page) { Capybara::Node::Simple.new(@response.body) }
    it "should be successfull" do
      get :new
      response.should be_success
      assigns[:chattel].should be_kind_of(Chattel)
      page.should have_selector('form[enctype="multipart/form-data"] input[type=file]#chattel_attachment')
    end
  end


  describe "index" do
    before do
      @c = Chattel.create(owner: FactoryGirl.create(:identity))
      sign_in @c.owner.login_credential
    end
    it "should get a list" do
      get :index
      assigns[:chattels].should include @c
      response.should be_success
    end
  end

  describe "describe" do
    before do
      cred = FactoryGirl.create :login_credential
      @pool = FactoryGirl.create(:pool, owner: cred.identities.first)
      @c = Chattel.create(owner: @pool.owner)
      @l = JobLogItem.create
      sign_in @pool.owner.login_credential
    end
    it "should be successful" do
      get :describe, :id=>@c, :log=>@l, :pool_id => @pool
      response.should be_success
      assigns[:pool].should == @pool
      assigns[:chattel].should == @c
      assigns[:log].should == @l
    end
  
  end

end
