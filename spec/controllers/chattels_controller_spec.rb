require 'spec_helper'

describe ChattelsController do

  it "should have routes" do
    {:get=>'/matt/chattels/new'}.should route_to(:controller=>'chattels', :action=>'new', :identity_id=>'matt')
    {:post=>'/matt/chattels'}.should route_to(:controller=>'chattels', :action=>'create', :identity_id=>'matt')
    {:get=>'/matt/marpa/chattels/3/describe'}.should route_to(:controller=>'chattels', :action=>'describe', :id=>'3', :pool_id=>'marpa', :identity_id=>'matt')
  end

  describe "new" do
    before do
      @identity = FactoryGirl.create :identity
      sign_in @identity.login_credential
    end
    render_views
    let(:page) { Capybara::Node::Simple.new(@response.body) }
    it "should be successfull" do
      get :new, identity_id: @identity.short_name
      response.should be_success
      assigns[:chattel].should be_kind_of(Chattel)
      page.should have_selector("form[enctype=\"multipart/form-data\"] input[type=file]#_#{@identity.short_name}_chattels_attachment")
    end
  end


  describe "index" do
    before do
      @c = Chattel.create(owner: FactoryGirl.create(:identity))
      sign_in @c.owner.login_credential
    end
    it "should get a list" do
      get :index, identity_id: 'matt'
      assigns[:chattels].should include @c
      response.should be_success
    end
  end

  describe "describe" do
    before do
      @identity = FactoryGirl.create :identity
      @pool = FactoryGirl.create(:pool, owner: @identity)
      @c = Chattel.create(owner: @pool.owner)
      @l = JobLogItem.create
      sign_in @pool.owner.login_credential
    end
    it "should be successful" do
      get :describe, :id=>@c, :log=>@l, :pool_id => @pool, identity_id: @identity.short_name
      response.should be_success
      assigns[:pool].should == @pool
      assigns[:chattel].should == @c
      assigns[:log].should == @l
    end
  
  end

end
