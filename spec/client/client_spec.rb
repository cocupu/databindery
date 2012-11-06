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


    describe "models" do
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
    end

    describe "node" do
      before do
        @m = Cocupu::Model.new({'identity' =>@ident.short_name, 'pool'=>@pool.short_name, 'name'=>"Car"})
        @m.save
      end
      it "should create nodes" do
        n = Cocupu::Node.new({'identity'=>@ident.short_name, 'pool'=>@pool.short_name, 'model_id' => @m.id, 'data' => {"name"=>"Ferrari", "date_completed"=>"Nov 10, 2012"}})
        n.save
      end
      it "should have associations" do
        n = Cocupu::Node.new({'identity'=>@ident.short_name, 'pool'=>@pool.short_name, 'model_id' => @m.id})
        n.associations = {talks: ["12b6e7b0-ea2c-012f-5ad3-3c075405d3d7", "32b6e7b0-ea2c-012f-5ad3-3c075405d3d7"]}
        n.save
      end
    end
  end
end
