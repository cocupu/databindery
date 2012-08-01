require 'spec_helper'

describe Node do
  before :all do
    @pool = Pool.create!(:owner=>Identity.create!)
  end
  before do
    subject.model = Model.create!(name: "Test Model", :owner=>Identity.create!)
  end
  it "should store a hash of data" do
    subject.data = {:foo =>'bar', 'boop' =>'bop'}
    subject.data.should == {:foo =>'bar', 'boop' =>'bop'}
  end
  it "should create a persistent_id when created" do
    subject.pool = @pool
    subject.persistent_id.should be_nil
    subject.save!
    subject.persistent_id.should_not be_nil
  end
  it "should create a new version when it's changed" do
    subject.pool = @pool
    subject.save!
    identity = Identity.create
    subject.update_attributes(:identity_id=>identity.id, :data=>{'boo'=>'bap'})
    new = Node.find_all_by_persistent_id(subject.persistent_id)
    new.length.should == 2
  end
  it "should create a new changeset when it's changed"
  it "should store it's parent"
  it "should show the difference between two versions"

  it "should have a model" do
    model = Model.create
    instance = Node.new(:model=>model)
    instance.model.should == model
  end
  it "should not be valid unless it has a model and pool" do
    instance = Node.new()
    instance.should_not be_valid
    instance.model = Model.create
    instance.should_not be_valid
    instance.pool = Pool.create
    instance.should be_valid
  end


  describe "with data" do
    before do
      @pool = FactoryGirl.create(:pool)
      @model = Model.create(name: "Mods and Rockers")
      @model.fields = {'f1'=>'Field one'}
      @model.save

      @instance = Node.new(model: @model, pool: @pool, data: {'f1'=>'good'})
    end

    it "should produce a solr document" do
      @instance.to_solr(@model.fields).should == {'id'=>@instance.persistent_id, 'version_s'=>@instance.id, 'model' =>'Mods and Rockers', "f1_s"=>"good", 'pool_s' => @pool.id}
    end
  end

end
