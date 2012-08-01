require 'spec_helper'

describe ChattelsController do

  it "should have routes" do
    {:get=>'/chattels/new'}.should route_to(:controller=>'chattels', :action=>'new')
    {:post=>'/chattels'}.should route_to(:controller=>'chattels', :action=>'create')
    {:get=>'/chattels/3/describe'}.should route_to(:controller=>'chattels', :action=>'describe', :id=>'3')
  end

  describe "new" do
    render_views
    let(:page) { Capybara::Node::Simple.new(@response.body) }
    it "should be successfull" do
      get :new
      response.should be_success
      assigns[:chattel].should be_kind_of(Chattel)
      page.should have_selector('form[enctype="multipart/form-data"] input[type=file]#chattel_attachment')
    end
  end

  describe "create" do
    it "should be successfull" do
      mock_queue = mock('queue')
      Carrot.should_receive(:queue).with('decompose_spreadsheet').and_return(mock_queue)
      mock_log = stub("log", :id=>'6HceCIKd3ucLNco9583DVnmGW5E')
      JobLogItem.should_receive(:create).and_return(mock_log)
      mock_queue.should_receive(:publish).with('6HceCIKd3ucLNco9583DVnmGW5E')

      post :create, :chattel => {:attachment=> fixture_file_upload(Rails.root + 'spec/fixtures/images/rails.png', 'image/png')}
      assigns[:chattel].should be_persisted
      assigns[:chattel].attachment.exists?.should be_true
      response.should redirect_to(describe_chattel_path(assigns[:chattel], :log=>assigns[:log].id))
    end
  end

  describe "index" do
    before do
      @c = Chattel.create(owner: FactoryGirl.create(:identity))
    end
    it "should get a list" do
      get :index
      assigns[:chattels].should include @c
      response.should be_success
    end
  end

  describe "describe" do
    before do
      @c = Chattel.create(owner: FactoryGirl.create(:identity))
      @l = JobLogItem.create
    end
    it "should be successful" do
      get :describe, :id=>@c.id, :log=>@l.id
      assigns[:chattel].should == @c
      assigns[:log].should == @l
      response.should be_success
    end
  
  end

end
