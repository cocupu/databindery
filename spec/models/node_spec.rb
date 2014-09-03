require 'spec_helper'

describe Node do
  let(:identity) { FactoryGirl.create :identity }
  let(:pool){ FactoryGirl.create :pool, :owner=>identity }
  let(:model) do
    FactoryGirl.create(:model,
                       fields_attributes: [{'code' => 'first_name', 'multivalue' => false}, {'code' => 'last_name'}, {'code' => 'title', 'multivalue' => true}],
                       label: 'last_name', associations_attributes: [{name: 'authors', references: ref.id}])
  end
  let(:ref) do
    FactoryGirl.create(:model,
                       fields_attributes: [{'code' => 'first_name'}, {'code' => 'last_name'}, {'code' => 'title'}],
                       label: 'last_name')
  end

  before do
    subject.model = model
  end

  it "should use persistent_id as to_param" do
    subject.pool = pool
    subject.save!
    subject.to_param.should == subject.persistent_id
  end


  it "should store fields and associations in one 'data' attribute hash" do
    true == false
  end

  it "should store a hash of data" do
    subject.data = {:foo =>'bar', 'boop' =>'bop'}
    subject.data.should == {:foo =>'bar', 'boop' =>'bop'}
    subject.pool = pool
    subject.save!
    subject.reload.data.should == {:foo =>'bar', 'boop' =>'bop'}
  end
  it "should store a hash of associations" do
    Node.any_instance.stub(:solr_associations).and_return({}) # prevent solr_associations from trying to retrieve metadata from Nodes that don't actually exist! Must stub on any_instance because .update creates a new node.
    subject.associations = { 'authors' =>[ "123", "3232"], 'undefined' =>["882"]}
    subject.associations.should == { 'authors' =>[ "123", "3232"], 'undefined' =>["882"]}
    subject.pool = pool
    subject.save!
    subject.associations.should == { 'authors' =>[ "123", "3232"], 'undefined' =>["882"]}

    ### Test copy-on-write
    subject.associations['authors'] << "888"
    subject.save!
    new_subject = Node.latest_version(subject.persistent_id)
    new_subject.associations.should == { 'authors' =>[ "123", "3232", "888"], 'undefined' =>["882"]}
  end

  describe "as_json" do
    it "should include identity and pool short names" do
      subject.pool = pool
      json = subject.as_json
      json["pool"].should == pool.short_name
      json["identity"].should == identity.short_name
    end
  end
  describe "associations_for_json" do
    before do
      @author_model = FactoryGirl.create(:model, name: 'Author', label: 'full_name', 
          fields_attributes: [{"name"=>"Name", "type"=>"TextField", "uri"=>"dc:description", "code"=>"full_name"}],
          owner: identity)#, :associations=>[{:name=>'books', :type=>'Belongs To', :references=>@book_model.id}])
      subject.model = FactoryGirl.create(:model, name: 'Book', owner: identity, associations_attributes: [{:name=>'Contributing Authors', :code=>'contributing_authors', :references=>@author_model.id}])
      @author1 = FactoryGirl.create(:node, model: @author_model, pool: pool, data: {'full_name' => 'Agatha Christie'})
      @author2 = FactoryGirl.create(:node, model: @author_model, pool: pool, data: {'full_name' => 'Raymond Chandler'})
      @publisher_model = FactoryGirl.create(:model, name: 'Publisher', label: 'name', 
          fields_attributes: [{"name"=>"Name", "type"=>"TextField", "uri"=>"dc:description", "code"=>"name"}],
          owner: identity)
      @publisher = FactoryGirl.create(:node, model: @publisher_model, pool: pool, data: {'name' => 'Simon & Schuster Ltd.'})
      @file = FactoryGirl.create(:node, model: Model.file_entity, pool: pool, data: {})
      subject.associations['contributing_authors'] = [@author1.persistent_id, @author2.persistent_id]
      subject.associations['undefined'] = [@publisher.persistent_id]
      subject.files << @file
    end

    it "should return a hash, where the association name is the key" do
      obj = subject.associations_for_json
      obj['Contributing Authors'].should == [{"id"=>@author1.persistent_id, "persistent_id"=>@author1.persistent_id,
          "title"=>"Agatha Christie"},
         {"id"=>@author2.persistent_id, "persistent_id"=>@author2.persistent_id,
          "title"=>"Raymond Chandler"}]

      obj['undefined'].should == [{'id'=>@publisher.persistent_id, "persistent_id"=>@publisher.persistent_id,
          "title"=>'Simon & Schuster Ltd.'}]
      obj['files'].should == [{'id'=>@file.persistent_id, "persistent_id"=>@file.persistent_id,
          "title"=>@file.persistent_id}]
    end

    it "should not return strings where there should be an array of ids" do
      subject.pool = pool
      subject.associations["contributing_authors"] = ""
      subject.associations_for_json["contributing_authors"].should be_nil
      subject.as_json["contributing_authors"].should be_nil
      # Other variations
      subject.associations["contributing_authors"] = [""]
      subject.associations_for_json["contributing_authors"].should be_nil
      subject.associations["contributing_authors"] = nil
      subject.associations_for_json["contributing_authors"].should be_nil
    end

  end

  it "should create a persistent_id when created" do
    subject.pool = pool
    subject.persistent_id.should be_nil
    subject.save!
    subject.persistent_id.should_not be_nil
  end

  it "should have a title" do
    subject.title.should == subject.persistent_id
  end

  it "should track who made changes" do
    identity1 = find_or_create_identity("bob")
    identity2 = find_or_create_identity("chinua")
    subject.pool = pool
    subject.save!
    subject.modified_by.should be_nil
    original = subject
    subject.update_attributes(:modified_by=>identity1, :data=>{'boo'=>'bap'})
    subject.modified_by.should == identity1
    v1 = subject.latest_version
    subject.update_attributes(:modified_by=>identity2, :data=>{'boo'=>'bappy'})
    subject.modified_by.should == identity2   
    v2 = subject.latest_version
    Node.find(original.id).modified_by.should be_nil
    Node.find(v1.id).modified_by.should == identity1
    Node.find(v2.id).modified_by.should == identity2
    identity1.changes.should == [v1]
    identity2.changes.should == [v2]
    subject.update_attributes(:data=>{'boo'=>'lollipop'})
    subject.latest_version.modified_by.should be_nil
  end
  it "should reset modified_by whenever attributes change" do
    identity = find_or_create_identity("bob")
    identity2 = find_or_create_identity("chinua")
    subject.modified_by = identity
    subject.modified_by.should == identity
    subject.attributes = {:data=>{'boo'=>'bap'}}
    subject.modified_by.should be_nil
    subject.attributes = {modified_by: identity2, :data=>{'boo'=>'bapper'}}
    subject.modified_by.should == identity2
    subject.update_attributes(:data=>{'boo'=>'bapperest'})
    subject.modified_by.should be_nil
  end
  it "should copy on write (except id, parent_id and timestamps)" do
    subject.pool = pool
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

  describe "with data" do
    before do
      subject.pool = pool
      subject.data = {'f1'=>'good', 'first_name' => 'Heathcliff', 'last_name' => 'Huxtable', 'title'=>'Dr.'}
    end
    it "should read title from field designated by model.label" do
      subject.title.should == 'Huxtable'
    end
  end

end
