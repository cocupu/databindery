require 'spec_helper'

describe Node do
  before :all do
    @pool = FactoryGirl.create :pool
  end
  before do
    @ref = FactoryGirl.create(:model)
    subject.model = FactoryGirl.create(:model, 
                      fields: [{code: 'first_name'}, {code: 'last_name'}, {code: 'title'}],
                      label: 'last_name', associations: [{type: 'Has Many', name: 'authors', references: @ref.id}])
  end

  it "should use persistent_id as to_param" do
    subject.pool = @pool
    subject.save!
    subject.to_param.should == subject.persistent_id
  end
  it "should have a binding" do
    subject.binding = '0B4oXai2d4yz6eENDUVJpQ1NkV3M'
    subject.binding.should == '0B4oXai2d4yz6eENDUVJpQ1NkV3M'
  end
  it "should store a hash of data" do
    subject.data = {:foo =>'bar', 'boop' =>'bop'}
    subject.data.should == {:foo =>'bar', 'boop' =>'bop'}
    subject.pool = @pool
    subject.save!
    subject.reload.data.should == {:foo =>'bar', 'boop' =>'bop'}
  end
  it "should store a hash of associations" do
    subject.associations = { 'authors' =>[ 123, 3232], 'undefined' =>[882]}
    subject.associations.should == { 'authors' =>[ 123, 3232], 'undefined' =>[882]}
    subject.pool = @pool
    subject.save!
    subject.associations.should == { 'authors' =>[ 123, 3232], 'undefined' =>[882]}
    subject.associations['authors'] << 888

    ### Test copy-on-write
    subject.save!
    new_subject = Node.latest_version(subject.persistent_id)
    new_subject.associations.should == { 'authors' =>[ 123, 3232, 888], 'undefined' =>[882]}
  end

  it "should create a persistent_id when created" do
    subject.pool = @pool
    subject.persistent_id.should be_nil
    subject.save!
    subject.persistent_id.should_not be_nil
  end

  it "should have a title" do
    subject.title.should == subject.persistent_id
  end
  it "should create a new version when it's changed" do
    subject.pool = @pool
    subject.save!
    identity = FactoryGirl.create(:identity)
    subject.update_attributes(:identity_id=>identity.id, :data=>{'boo'=>'bap'})
    new = Node.find_all_by_persistent_id(subject.persistent_id)
    new.length.should == 2
  end
  it "should copy on write (except id, parent_id and timestamps)" do
    subject.pool = @pool
    subject.save!
    subject.attributes = {:data=>{'boo'=>'bap'}}
    new_subject = subject.update
    old_attributes = subject.attributes
    old_attributes.delete('id')
    old_attributes.delete('parent_id')
    old_attributes.delete('created_at')
    old_attributes.delete('updated_at')

    new_attributes = new_subject.attributes
    new_attributes.delete('id')
    new_attributes.delete('created_at')
    new_attributes.delete('updated_at')
    new_attributes.delete('parent_id').should == subject.id
    new_attributes.should == old_attributes
  end

  it "should get the latest version" do
    subject.pool = @pool
    subject.save!
    subject.attributes = {:data=>{'boo'=>'bap'}}
    new_subject = subject.update

    Node.latest_version(subject.persistent_id).should == new_subject
  end
  describe "find_by_persistent_id" do
    it "should always return the latest version" do
      subject.pool = @pool
      subject.save!
      subject.attributes = {:data=>{'boo'=>'bap'}}
      new_subject = subject.update
      Node.latest_version(subject.persistent_id).should == Node.find_by_persistent_id(subject.persistent_id) 
    end
  end
  it "should create a new changeset when it's changed"
  it "should store it's parent"
  it "should show the difference between two versions"

  it "should have a model" do
    model = Model.create
    instance = Node.new
    instance.model=model
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

  it "should index itself when it's saved" do
    Cocupu.should_receive :index
    Cocupu.solr.should_receive :commit
    subject.pool = @pool 
    subject.model = FactoryGirl.create(:model)
    subject.save!
  end


  describe "with data" do
    before do
      @pool = FactoryGirl.create(:pool)
      subject.pool = @pool 
      subject.data = {'f1'=>'good', 'first_name' => 'Heathcliff', 'last_name' => 'Huxtable', 'title'=>'Dr.'}
    end

    it "should produce a solr document" do
      # f1 is not defined as a field on the model, so it's not indexed.
      subject.to_solr.should == {'id'=>subject.persistent_id, 'version'=>subject.id, 'model_name' =>subject.model.name, 'pool' => @pool.id, 'format'=>'Node', 'model'=>subject.model.id, 'title'=>'Huxtable', 'first_name_t'=>'Heathcliff', 'first_name_facet'=>'Heathcliff', 'last_name_t'=>'Huxtable', 'last_name_facet'=>'Huxtable', 'title_t' => 'Dr.', 'title_facet' => 'Dr.'}
    end
    it "should have a title" do
      subject.title.should == 'Huxtable'
    end
  end

end
