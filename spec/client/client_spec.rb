require 'spec_helper'
require File.expand_path('../../../client/client',  __FILE__)

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
    sleep(1)
  end

  after do
    ## TODO, not sure why this doesn't work.
    #@ident.login_credential.destroy
  end

  it "should sign in" do
    b = Bindery.new(@ident.login_credential.email, 'notblank', 8989)
  end

  describe "when signed in" do
    before do
      @b = Bindery.new(@ident.login_credential.email, 'notblank', 8989)
    end

    it "should get the pools for an identity" do
      @b.identity(@ident.short_name).pools.inspect
    end

    it "should get a single pool" do
      @b.identity(@ident.short_name).pool(@pool.short_name).models.inspect
    end


    describe "models" do
      it "should create a new model" do
        m = Bindery::Model.new({'identity' =>@ident.short_name, 'pool'=>@pool.short_name, 'name'=>"Car"}, @b)
        m.save
      end

      it "should update models" do
        ref = Bindery::Model.new({'identity' =>@ident.short_name, 'pool'=>@pool.short_name, 'name'=>"Stuff"}, @b)
        ref.save
        m = Bindery::Model.new({'identity' =>@ident.short_name, 'pool'=>@pool.short_name, 'name'=>"Car"}, @b)
        m.save
        m.fields = [{"name"=>"Name", "type"=>"text", "uri"=>"", "code"=>"name"}, {"name"=>"Date Completed", "type"=>"text", "uri"=>"", "code"=>"date_completed"}]
        m.associations = [ {"type"=>"Has One","name"=>"recording","references"=>ref.id}] #service throws a 404 if the references isn't a valid model.id
        m.label = 'name'
        m.save 
      end
    end

    describe "node" do
      before do
        @m = Bindery::Model.new({'identity' =>@ident.short_name, 'pool'=>@pool.short_name, 'name'=>"Car"}, @b)
        @m.save
      end
      it "should create nodes" do
        n = Bindery::Node.new({'identity'=>@ident.short_name, 'pool'=>@pool.short_name, 'model_id' => @m.id, 'data' => {"name"=>"Ferrari", "date_completed"=>"Nov 10, 2012"}}, @b)
        n.save
      end
      it "should have associations" do
        n = Bindery::Node.new({'identity'=>@ident.short_name, 'pool'=>@pool.short_name, 'model_id' => @m.id}, @b)
        n.associations = {talks: ["12b6e7b0-ea2c-012f-5ad3-3c075405d3d7", "32b6e7b0-ea2c-012f-5ad3-3c075405d3d7"]}
        n.save
      end
    end
  end
end
