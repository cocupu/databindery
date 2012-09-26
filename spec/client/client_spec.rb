require 'spec_helper'
require File.expand_path('../../../client/client',  __FILE__)

describe "API" do
  self.use_transactional_fixtures = false
  before do
    @pool = FactoryGirl.create(:pool)
    @ident = @pool.owner
  end

  after do
    @ident.login_credential.destroy
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
        m = Bindery::Model.new({'identity' =>@ident.short_name, 'pool'=>@pool.short_name, 'name'=>"Car"}, @b)
        m.save
        m.fields = [{"name"=>"Name", "type"=>"text", "uri"=>"", "code"=>"name"}, {"name"=>"Date Completed", "type"=>"text", "uri"=>"", "code"=>"date_completed"}]
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
    end
  end
end
