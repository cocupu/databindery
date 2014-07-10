require 'spec_helper'

describe Node do
  before do
    @pool = FactoryGirl.create :pool
    @ref = FactoryGirl.create(:model,
                              fields: [{'code' => 'first_name'}, {'code' => 'last_name'}, {'code' => 'title'}],
                              label: 'last_name')
    subject.model = FactoryGirl.create(:model,
                      fields: [{'code' => 'first_name', 'multiple' => false}, {'code' => 'last_name'}, {'code' => 'title', 'multiple' => true}],
                      label: 'last_name', associations: [{type: 'Has Many', name: 'authors', references: @ref.id}])
  end

  describe "#find_by_identifier" do
    before do
      @node = Bindery::Spreadsheet.create(pool: @pool, model: Model.file_entity)
    end
    it "should accept Node persistent_ids" do
      Node.should_receive(:find_by_persistent_id).with(@node.persistent_id).and_return(@node)
      Node.find_by_identifier(@node.persistent_id).should == @node
    end
    it "should accept Node ids" do
      Node.should_receive(:find).with(@node.id).and_return(@node)
      Node.find_by_identifier(@node.id).should == @node
    end
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
    Node.any_instance.stub(:solr_associations).and_return({}) # prevent solr_associations from trying to retrieve metadata from Nodes that don't actually exist! Must stub on any_instance because .update creates a new node.
    subject.associations = { 'authors' =>[ "123", "3232"], 'undefined' =>["882"]}
    subject.associations.should == { 'authors' =>[ "123", "3232"], 'undefined' =>["882"]}
    subject.pool = @pool
    subject.save!
    subject.associations.should == { 'authors' =>[ "123", "3232"], 'undefined' =>["882"]}

    ### Test copy-on-write
    subject.associations['authors'] << "888"
    subject.save!
    new_subject = Node.latest_version(subject.persistent_id)
    new_subject.associations.should == { 'authors' =>[ "123", "3232", "888"], 'undefined' =>["882"]}
  end

  describe "reify_association" do
    it "should reify_associations" do
      author1 = Node.create!(pool:@pool, model:@ref)
      author2 = Node.create!(pool:@pool, model:@ref)
      subject.associations["authors"] = [author1.persistent_id, author2.persistent_id]
      subject.reify_association("authors").should == [author1, author2]
    end
  end
  describe "as_json" do
    before do
      @identity = FactoryGirl.create :identity
      @pool = FactoryGirl.create :pool, :owner=>@identity
    end
    it "should include identity and pool short names" do
      subject.pool = @pool
      json = subject.as_json
      json["pool"].should == @pool.short_name
      json["identity"].should == @identity.short_name
    end
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
      subject.pool = @pool
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

  describe "files setter and getter" do
    before do
      @file1 = FactoryGirl.create(:node, model: Model.file_entity, pool: @pool)
      @file2 = FactoryGirl.create(:node, model: Model.file_entity, pool: @pool)
      @file3 = FactoryGirl.create(:node, model: Model.file_entity, pool: @pool)      
    end
    it "should match with file_ids array and should operate on FileEntity nodes" do
      subject.files.should be_empty
      subject.send(:file_ids).should be_empty
      subject.files << @file1
      subject.files << @file2
      subject.send(:file_ids).should == [@file1.persistent_id, @file2.persistent_id]
      subject.files.should == [@file1, @file2]
      subject.files.unshift(@file3)
      subject.files.should == [@file3, @file1, @file2]
      subject.send(:file_ids).should == [@file3.persistent_id, @file1.persistent_id, @file2.persistent_id]
      subject.associations["files"].should == subject.send(:file_ids)
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
      stub_ul.stub(:mime_type => 'image/png')
      subject.attach_file('my_file.png', stub_ul)
      subject.files.size.should == 1
      file_node = Node.latest_version(subject.files.first.persistent_id)
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
    subject.update_attributes(:data=>{'boo'=>'bap'})
    all_versions = Node.where(persistent_id: subject.persistent_id).to_a
    all_versions.length.should == 2
  end
  it "should track who made changes" do
    identity1 = find_or_create_identity("bob")
    identity2 = find_or_create_identity("chinua")
    subject.pool = @pool
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

  describe "solr_name" do
    it "should remove whitespaces" do
      Node.solr_name("one two\t\tthree").should == "one_two_three_s"
    end
    it "should use the type" do
      Node.solr_name("one two", :type=>'facet').should == "one_two_facet"
    end
    it "should use the prefix" do
      Node.solr_name("first name", :prefix=>'related_object__', :type=>'facet').should == "related_object__first_name_facet"
    end
    it "should handle special terms" do
      Node.solr_name("model_name").should == "model_name"
      Node.solr_name("model").should == "model"

    end
  end


  describe "with data" do
    before do
      @pool = FactoryGirl.create(:pool)
      subject.pool = @pool 
      subject.data = {'f1'=>'good', 'first_name' => 'Heathcliff', 'last_name' => 'Huxtable', 'title'=>'Dr.'}
    end

    it "should produce a solr document with correct field names, skipping fields that are not defined in the model" do
      # f1 is not defined as a field on the model, so it's not indexed.
      subject.to_solr.should == {'id'=>subject.persistent_id, 'version'=>subject.id, 'model_name' =>subject.model.name, 'pool' => @pool.id, 'format'=>'Node', 'model'=>subject.model.id, 'title'=>'Huxtable', 'first_name_s'=>'Heathcliff', 'first_name_facet'=>'Heathcliff', 'last_name_s'=>'Huxtable', 'last_name_facet'=>'Huxtable', 'title_t' => 'Dr.', 'title_facet' => 'Dr.'}
    end
    it "should have a title" do
      subject.title.should == 'Huxtable'
    end
  end

  describe "with associations" do
    before do
      @identity = FactoryGirl.create :identity
      @pool = FactoryGirl.create :pool, :owner=>@identity
      @author_model = FactoryGirl.create(:model, name: 'Author', label: 'full_name', 
          fields: [{"name"=>"Name", "type"=>"Text Field", "uri"=>"dc:description", "code"=>"full_name"}.with_indifferent_access],
          owner: @identity)
      @author1 = FactoryGirl.create(:node, model: @author_model, pool: @pool, data: {'full_name' => 'Agatha Christie'})
      @author2 = FactoryGirl.create(:node, model: @author_model, pool: @pool, data: {'full_name' => 'Raymond Chandler'})

      subject.model = FactoryGirl.create(:model, name: 'Book', label: 'book_title', owner: @identity,
          fields: [{"code" => "book_title", "name"=>"Book title"}],
          :associations => [{:name=>'Contributing Authors', :code=>'contributing_authors', :type=>'Ordered List', :references=>@author_model.id}.with_indifferent_access])
      subject.data = {'book_title'=>'How to write mysteries'}
      subject.associations['contributing_authors'] = [@author1.persistent_id, @author2.persistent_id]
      subject.pool = @pool
      subject.save!
    end
    it "should index the properties of the child associations and add their persistent ids to an bindery__associations_facet field" do
      subject.to_solr.should == {'id'=>subject.persistent_id, 'version'=>subject.id, 'model_name' =>subject.model.name, 'pool' => @pool.id, 
        'format'=>'Node', 'model'=>subject.model.id, 
        'contributing_authors_facet'=>['Agatha Christie', 'Raymond Chandler'],
        'contributing_authors_t'=>['Agatha Christie', 'Raymond Chandler'],
        'contributing_authors__full_name_t'=>['Agatha Christie', 'Raymond Chandler'],
        'contributing_authors__full_name_facet'=>['Agatha Christie', 'Raymond Chandler'],
        "book_title_facet" => "How to write mysteries",
        "book_title_s" => "How to write mysteries",
        "title" => "How to write mysteries",
        "bindery__associations_facet" => [@author1.persistent_id, @author2.persistent_id]
      }
    end
    describe "find_association" do
      it "should return all of the nodes pointed to by a particular association" do
        nodes = subject.find_association("contributing_authors")
        nodes.length.should == 2
        nodes.should include(@author1)
        nodes.should include(@author2)
      end
      it "should return an nil if association is nil or a string" do
        subject.find_association("foo").should be_nil
        subject.associations["foo"] = ""
        subject.find_association("foo").should be_nil
      end
    end
    describe "incoming" do
      it "should return all of the nodes pointing to the current object" do
        @author1.incoming.should == [subject]
      end
    end
  end

end
