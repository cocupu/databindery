require 'spec_helper'
require 'cocupu'

describe "API" do
  self.use_transactional_fixtures = false
  before do
    @pool = FactoryGirl.create(:pool)
    @ident = @pool.owner
  end

  before :all do
    @pid = fork do
      exec("unicorn_rails -p 8989 --env test")
    end
    sleep (10)
  end

  after :all do
    puts "Stopping server"
    Process.kill('TERM', @pid)
    puts "stopped"
    LoginCredential.destroy_all #Clean the DB, since we're not using transactions.
    sleep(1)
  end

  it "should sign in" do
    b = Cocupu.start(@ident.login_credential.email, 'notblank', 8989)
  end

  describe "when signed in" do
    before do
      @b = Cocupu.start(@ident.login_credential.email, 'notblank', 8989)
    end

    it "should get the pools for an identity" do
      @b.identity(@ident.short_name).pools.inspect
    end

    it "should get a single pool" do
      @b.identity(@ident.short_name).pool(@pool.short_name).models.inspect
    end

    #
    # Cocupu::Model
    #
    describe "models" do
      before do
        @model = FactoryGirl.create(:model, pool: @pool, fields_attributes:[{code:"description"},{code:"name"},{code:"date_completed"}])
        @model2 = FactoryGirl.create(:model, pool: @pool)
      end
      it "should create a new model" do
        m = Cocupu::Model.new({'identity' =>@ident.short_name, 'pool'=>@pool.short_name, 'name'=>"Car", "allow_file_bindings"=>"false"})
        m.save
        retrieved = Cocupu::Model.load(m.id)
        retrieved.allows_file_bindings?.should be_false
      end

      it "should update models" do
        ref = Cocupu::Model.new({'identity' =>@ident.short_name, 'pool'=>@pool.short_name, 'name'=>"Stuff"})
        ref.save
        m = Cocupu::Model.new({'identity' =>@ident.short_name, 'pool'=>@pool.short_name, 'name'=>"Car"})
        m.save
        m.fields = [{"name"=>"Name", "type"=>"TextField", "uri"=>"", "code"=>"name"}, {"name"=>"Date Completed", "type"=>"DateField", "uri"=>"", "code"=>"date_completed"}]
        m.associations = [ {"name"=>"recording","references"=>ref.id}] #service throws a 404 if the references isn't a valid model.id
        m.label = 'name'
        m.allow_file_bindings = false
        m.save 
        retrieved = Cocupu::Model.load(m.id)
        retrieved.allows_file_bindings?.should be_false
      end
      
      it "should find all models" do
        results = Cocupu::Model.find(@ident.short_name, @pool.short_name, :all)
        results.count.should == 2
        results.each {|m| m.should be_instance_of Cocupu::Model}
      end
      
      it "should load single models" do
        model = Cocupu::Model.load(@model.id)
        model.should be_instance_of Cocupu::Model
        model.id.should == @model.id
        model.fields.should == JSON.parse(@model.fields.to_json)
        model.pool.should == @model.pool.short_name
        model.identity.should == @model.pool.owner.short_name
      end

      it "should convert data keys to field identifiers for single hashes and arrays of hashes" do
        data_to_convert = {"description"=>"Poet, prominent figure in the Harlem Renaissance","name"=>"Wallace Thurman", "date_completed"=>"2014-09-18"}
        model = Cocupu::Model.load(@model.id)
        description_field = model.fields.select {|f| f["code"] == "description"}.first
        name_field = model.fields.select {|f| f["code"] == "name"}.first
        date_completed_field = model.fields.select {|f| f["code"] == "date_completed"}.first
        expect(model.convert_data_keys(data_to_convert)).to eq({description_field["id"]=>"Poet, prominent figure in the Harlem Renaissance", name_field["id"] => "Wallace Thurman", date_completed_field["id"] => "2014-09-18"})
        expect(model.convert_data_keys([data_to_convert]).first).to eq({description_field["id"]=>"Poet, prominent figure in the Harlem Renaissance", name_field["id"] => "Wallace Thurman", date_completed_field["id"] => "2014-09-18"})
      end
    end

    #
    # Cocupu::Node
    #
    describe "node" do
      before do
        @m = Cocupu::Model.new({'identity' =>@ident.short_name, 'pool'=>@pool.short_name, 'name'=>"Car"})
        @m.save
      end
      it "should find nodes" do
        model = FactoryGirl.create(:model, pool: @pool)
        node1 = FactoryGirl.create(:node, model: model, pool: @pool)
        node2 = FactoryGirl.create(:node, model: model, pool: @pool)
        othernode = FactoryGirl.create(:node, model: FactoryGirl.create(:model), pool: @pool)
        results = Cocupu::Node.find(@ident.short_name, @pool.short_name, :model_id=>model.id)
        results.count.should == 2
        results.each do |n| 
          n.should be_instance_of Cocupu::Node
          n.model_id.should == model.id
          n.persistent_id.should_not == othernode.persistent_id
        end
      end
      it "should find nodes with fielded search" do
        @auto_model = FactoryGirl.create(:model, pool: @pool, name:"/automotive/model", fields_attributes: [{"code"=>"name", "name"=>"Name"},{"code"=>"year", "name"=>"Year"}, {"code"=>"make", "name"=>"Make", "uri"=>"/automotive/model/make"}])

        @node1 = Node.create!(model:@auto_model, pool: @pool, data:@auto_model.convert_data_field_codes_to_id_strings("year"=>"2009", "make"=>"/en/ford", "name"=>"Ford Taurus"))
        @node2 = Node.create!(model:@auto_model, pool: @pool, data:@auto_model.convert_data_field_codes_to_id_strings("year"=>"2011", "make"=>"/en/ford", "name"=>"Ford Taurus"))
        @node3 = Node.create!(model:@auto_model, pool: @pool, data:@auto_model.convert_data_field_codes_to_id_strings("year"=>"2013", "make"=>"Prius", "name"=>"Zippy"))
        @node4 = Node.create!(model:@auto_model, pool: @pool, data:@auto_model.convert_data_field_codes_to_id_strings("year"=>"2012", "make"=>"Prius", "name"=>"Recharge"))

        results = Cocupu::Node.find(@ident.short_name, @pool.short_name, "make" => "Prius")
        results.count.should == 2
        results.each do |n|
          n.should be_instance_of Cocupu::Node
          n.model_id.should == @auto_model.id
          [@node3.persistent_id, @node4.persistent_id].should include(n.persistent_id)
        end
        results = Cocupu::Node.find(@ident.short_name, @pool.short_name, "make" => "Prius", "year"=>"2012")
        results.count.should == 1
        results.first.persistent_id.should == @node4.persistent_id
      end
      it "should create nodes" do
        n = Cocupu::Node.new({'identity'=>@ident.short_name, 'pool'=>@pool.short_name, 'model_id' => @m.id, 'data' => {"name"=>"Ferrari", "date_completed"=>"Nov 10, 2012"}})
        n.save
      end
      it "should update nodes" do
        model = FactoryGirl.create(:model, pool: @pool)
        node = FactoryGirl.create(:node, model: model, pool: @pool, :data=>{'first_name'=>'Justin', 'last_name'=>'Coyne', 'title'=>'Mr.'})
        n = Cocupu::Node.new({'identity'=>@ident.short_name, 'pool'=>@pool.short_name, 'model_id' => model.id, 'data' => {"persistent_id"=>node.persistent_id,"name"=>"Ferrari", "date_completed"=>"Nov 10, 2012"}})
        n.save
      end
      it "should have associations" do
        n = Cocupu::Node.new({'identity'=>@ident.short_name, 'pool'=>@pool.short_name, 'model_id' => @m.id})
        n.associations = {talks: ["12b6e7b0-ea2c-012f-5ad3-3c075405d3d7", "32b6e7b0-ea2c-012f-5ad3-3c075405d3d7"]}
        n.save
      end
    end
    describe "Node#find_or_create" do
      before do
        @model = FactoryGirl.create(:model, pool: @pool, label: 'first_name',
                                    fields_attributes: [{:code=>'first_name'}, {:code=>'last_name'}, {:code=>'title'}])
        @node1 = FactoryGirl.create(:node, model: @model, pool: @pool, :data=>@model.convert_data_field_codes_to_id_strings('first_name'=>'Justin', 'last_name'=>'Coyne', 'title'=>'Mr.'))
        @node2 = FactoryGirl.create(:node, model: @model, pool: @pool, :data=>@model.convert_data_field_codes_to_id_strings('first_name'=>'Matt', 'last_name'=>'Zumwalt', 'title'=>'Mr.'))
        @node3 = FactoryGirl.create(:node, model: @model, pool: @pool, :data=>@model.convert_data_field_codes_to_id_strings('first_name'=>'Justin', 'last_name'=>'Ball', 'title'=>'Mr.'))
      end
      it "if a match exists should load the found node " do
        n = Cocupu::Node.find_or_create({'identity'=>@ident.short_name, 'pool'=>@pool.short_name, "node"=>{'model_id' => @model.id, :data=>@model.convert_data_field_codes_to_id_strings('first_name'=>'Justin', 'last_name'=>'Coyne', 'title'=>'Mr.')} })
        n.should be_instance_of Cocupu::Node
        n.persistent_id.should == @node1.persistent_id
        n.data.should == @model.convert_data_field_codes_to_id_strings('first_name'=>'Justin', 'last_name'=>'Coyne', 'title'=>'Mr.')
      end
      it "if no match exists should load the created Cocupu::Node" do
        count_before = Node.count
        n = Cocupu::Node.find_or_create({'identity'=>@ident.short_name, 'pool'=>@pool.short_name, "node"=>{'model_id' => @model.id, :data=>{'first_name'=>'Julius', 'last_name'=>'Caesar', 'title'=>'First Citizen'}} })
        Node.count.should == count_before + 1
        n.should be_instance_of Cocupu::Node
        n.data.should == {'first_name'=>'Julius', 'last_name'=>'Caesar', 'title'=>'First Citizen'}
      end
    end

    describe "Node#import" do
      before do
        @model = FactoryGirl.create(:model, pool: @pool)
      end
      it "should import nodes from an array of data records" do
        r1 = { 'f1' => 'A val' }
        r2 = { 'f1' => 'Another val' }
        nodes_before = Node.count
        response = Cocupu::Node.import({'identity'=>@ident.short_name, 'pool'=>@pool.short_name, "model_id"=>@model.id, "data"=>[r1, r2]})
        expect(response.body).to eq('{"failed_instances":[],"num_inserts":1}')
        expect(Node.count).to eq(nodes_before + 2)
        #expect(Node.last.data).to eq(r1)
        #expect(Node.find(Node.last.id+1).data).to eq(r2)
      end
    end
  
    #
    # Cocupu::Curator
    #
    describe "Curator" do
      describe "spawn_from_field" do
        before do
          @dest_model = FactoryGirl.create(:model, pool: @pool, label: 'full_name',
                                           fields_attributes: [{:code=>'full_name'}])
          @source_model = FactoryGirl.create(:model, pool: @pool, label: 'title',
                                             fields_attributes: [{:code=>'submitted_by'}, {:code=>'location'}, {:code=>'title'}])
          @node1 = FactoryGirl.create(:node, model: @source_model, pool: @pool, :data=>{'submitted_by'=>'Justin Coyne', 'location'=>'Malibu', 'title'=>'My Vacation'})
          @node2 = FactoryGirl.create(:node, model: @source_model, pool: @pool, :data=>{'submitted_by'=>'Matt Zumwalt', 'location'=>'Berlin', 'title'=>'My Holiday'})
          @node3 = FactoryGirl.create(:node, model: @source_model, pool: @pool, :data=>{'submitted_by'=>'Justin Coyne', 'location'=>'Bali', 'title'=>'My other Vacation'})
        end
        it "should Spawn new :destination_model nodes using the :source_field_name field from :source_model nodes, setting the extracted value as the :destination_field_name field on the resulting spawned nodes." do
          @dest_model.nodes.count.should == 0
          Cocupu::Curator.spawn_from_field(@ident, @pool, @source_model.id, "submitted_by", "creator", @dest_model.id, "full_name", :delete_source_value=>true)
          # Can't just use @dest_model.nodes to count the nodes because that returns all versions of each node (so it returns 4 nodes instead of 2 in this case)
          # Instead counting the number of unique persistent_ids in use by @dest_model.nodes
          # @dest_model.nodes.count.should == 2
          @dest_model.nodes.map {|node| node.persistent_id }.uniq.count.should == 2
          # One "Justin" node should have been spawned from 2 sources
          n1 = @node1.latest_version
          justin_node_id = n1.associations["creator"].first
          justin = Node.find_by_persistent_id(justin_node_id)
          justin.model.should == @dest_model
          justin.data["full_name"].should == "Justin Coyne"
          n3 = @node3.latest_version
          n3.associations["creator"].first.should == justin_node_id
          n1.data["submitted_by"].should be_nil
          n3.data["submitted_by"].should be_nil
          # One Matt node should have been spawned from 1 source
          n2 = @node2.latest_version
          matt_node_id = n2.associations["creator"].first
          matt = Node.find_by_persistent_id(matt_node_id)
          matt.model.should == @dest_model
          matt.data["full_name"].should == "Matt Zumwalt"
          n2.data["submitted_by"].should be_nil
        end
      end
    end
  end
end
