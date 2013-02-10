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
        @model = FactoryGirl.create(:model, pool: @pool)
        @model2 = FactoryGirl.create(:model, pool: @pool)
      end
      it "should create a new model" do
        m = Cocupu::Model.new({'identity' =>@ident.short_name, 'pool'=>@pool.short_name, 'name'=>"Car"})
        m.save
      end

      it "should update models" do
        ref = Cocupu::Model.new({'identity' =>@ident.short_name, 'pool'=>@pool.short_name, 'name'=>"Stuff"})
        ref.save
        m = Cocupu::Model.new({'identity' =>@ident.short_name, 'pool'=>@pool.short_name, 'name'=>"Car"})
        m.save
        m.fields = [{"name"=>"Name", "type"=>"text", "uri"=>"", "code"=>"name"}, {"name"=>"Date Completed", "type"=>"text", "uri"=>"", "code"=>"date_completed"}]
        m.associations = [ {"type"=>"Has One","name"=>"recording","references"=>ref.id}] #service throws a 404 if the references isn't a valid model.id
        m.label = 'name'
        m.save 
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
        model.fields.should == @model.fields
        model.pool.should == @model.pool.short_name
        model.identity.should == @model.pool.owner.short_name
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
                    fields: [{:code=>'first_name'}.with_indifferent_access, {:code=>'last_name'}.with_indifferent_access, {:code=>'title'}.with_indifferent_access])
        @node1 = FactoryGirl.create(:node, model: @model, pool: @pool, :data=>{'first_name'=>'Justin', 'last_name'=>'Coyne', 'title'=>'Mr.'})
        @node2 = FactoryGirl.create(:node, model: @model, pool: @pool, :data=>{'first_name'=>'Matt', 'last_name'=>'Zumwalt', 'title'=>'Mr.'})
        @node3 = FactoryGirl.create(:node, model: @model, pool: @pool, :data=>{'first_name'=>'Justin', 'last_name'=>'Ball', 'title'=>'Mr.'})
      end
      it "if a match exists should load the found node " do
        n = Cocupu::Node.find_or_create({'identity'=>@ident.short_name, 'pool'=>@pool.short_name, "node"=>{'model_id' => @model.id, :data=>{'first_name'=>'Justin', 'last_name'=>'Coyne', 'title'=>'Mr.'}} })
        n.should be_instance_of Cocupu::Node
        n.persistent_id.should == @node1.persistent_id
        n.data.should == {'first_name'=>'Justin', 'last_name'=>'Coyne', 'title'=>'Mr.'}
      end
      it "if no match exists should load the created Cocupu::Node" do
        count_before = Node.count
        n = Cocupu::Node.find_or_create({'identity'=>@ident.short_name, 'pool'=>@pool.short_name, "node"=>{'model_id' => @model.id, :data=>{'first_name'=>'Julius', 'last_name'=>'Caesar', 'title'=>'First Citizen'}} })
        Node.count.should == count_before + 1
        n.should be_instance_of Cocupu::Node
        n.data.should == {'first_name'=>'Julius', 'last_name'=>'Caesar', 'title'=>'First Citizen'}
      end
    end
  
    #
    # Cocupu::Curator
    #
    describe "Curator" do
      describe "spawn_from_field" do
        before do
          @dest_model = FactoryGirl.create(:model, pool: @pool, label: 'full_name',
                      fields: [{:code=>'full_name'}.with_indifferent_access])
          @source_model = FactoryGirl.create(:model, pool: @pool, label: 'title',
                      fields: [{:code=>'submitted_by'}.with_indifferent_access, {:code=>'location'}.with_indifferent_access, {:code=>'title'}.with_indifferent_access])
          @node1 = FactoryGirl.create(:node, model: @source_model, pool: @pool, :data=>{'submitted_by'=>'Justin Coyne', 'location'=>'Malibu', 'title'=>'My Vacation'})
          @node2 = FactoryGirl.create(:node, model: @source_model, pool: @pool, :data=>{'submitted_by'=>'Matt Zumwalt', 'location'=>'Berlin', 'title'=>'My Holiday'})
          @node3 = FactoryGirl.create(:node, model: @source_model, pool: @pool, :data=>{'submitted_by'=>'Justin Coyne', 'location'=>'Bali', 'title'=>'My other Vacation'})
        end
        it "should Spawn new :destination_model nodes using the :source_field_name field from :source_model nodes, setting the extracted value as the :destination_field_name field on the resulting spawned nodes." do
          @dest_model.nodes.count.should == 0
          Cocupu::Curator.spawn_from_field(@ident, @pool, @source_model.id, "submitted_by", "creator", @dest_model.id, "full_name")
          @dest_model.nodes.count.should == 2
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
