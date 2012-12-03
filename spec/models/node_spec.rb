require 'spec_helper'

describe Node do
  before do
    @pool = FactoryGirl.create :pool
    @ref = FactoryGirl.create(:model)
    subject.model = FactoryGirl.create(:model, 
                      fields: [{'code' => 'first_name'}, {'code' => 'last_name'}, {'code' => 'title'}],
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

  describe "associations_for_json" do
    before do
      @identity = FactoryGirl.create :identity
      pool = FactoryGirl.create :pool, :owner=>@identity
      @author_model = FactoryGirl.create(:model, name: 'Author', label: 'full_name', 
          fields: [{"name"=>"Name", "type"=>"Text Field", "uri"=>"dc:description", "code"=>"full_name"}.with_indifferent_access],
          owner: @identity)#, :associations=>[{:name=>'books', :type=>'Belongs To', :references=>@book_model.id}])
      subject.model = FactoryGirl.create(:model, name: 'Book', owner: @identity, :associations => [{:name=>'Contributing Authors', :code=>'contributing_authors', :type=>'Ordered List', :references=>@author_model.id}])
      @author1 = FactoryGirl.create(:node, model: @author_model, pool: pool, data: {'full_name' => 'Agatha Christie'})
      @author2 = FactoryGirl.create(:node, model: @author_model, pool: pool, data: {'full_name' => 'Raymond Chandler'})
      @publisher_model = FactoryGirl.create(:model, name: 'Publisher', label: 'name', 
          fields: [{"name"=>"Name", "type"=>"Text Field", "uri"=>"dc:description", "code"=>"name"}.with_indifferent_access],
          owner: @identity)
      @publisher = FactoryGirl.create(:node, model: @publisher_model, pool: pool, data: {'name' => 'Simon & Schuster Ltd.'})
      @file = FactoryGirl.create(:node, model: Model.file_entity, pool: pool, data: {})
      subject.associations['contributing_authors'] = [@author1.persistent_id, @author2.persistent_id]
      subject.associations['undefined'] = [@publisher.persistent_id]
      subject.associations['files'] = [@file.persistent_id]
    end

    it "should return a hash, where the association name is the key" do
      obj = subject.associations_for_json
      obj['Contributing Authors'].should == [{"id"=>@author1.persistent_id, "persistent_id"=>@author1.persistent_id,
          :title=>"Agatha Christie"},
         {"id"=>@author2.persistent_id, "persistent_id"=>@author2.persistent_id,
          :title=>"Raymond Chandler"}]

      obj['undefined'].should == [{'id'=>@publisher.persistent_id, "persistent_id"=>@publisher.persistent_id,
          :title=>'Simon & Schuster Ltd.'}]
      obj['files'].should == [{'id'=>@file.persistent_id, "persistent_id"=>@file.persistent_id,
          :title=>@file.persistent_id}]
    end

  end

  describe "attaching a file" do
    before do
      config = YAML.load_file(Rails.root + 'config/s3.yml')[Rails.env]
      @s3 = FactoryGirl.create(:s3_connection, config.merge(pool: @pool))
    end
    it "should store a list of attached files" do
      subject.files.size.should == 0
      subject.pool = @pool
      stub_ul = File.open(fixture_path + '/images/rails.png')
      stub_ul.stub(:content_type => 'image/png')
      subject.attach_file('my_file.png', stub_ul)
      subject.files.size.should == 1
      file_node = Node.latest_version(subject.files.first)
      file_node.file_name.should == 'my_file.png'
      file_node.content.should == File.open(fixture_path + '/images/rails.png', "rb").read
    end
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
    Bindery.should_receive :index
    Bindery.solr.should_receive :commit
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
