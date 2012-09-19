require 'spec_helper'

describe PoolsController do
  describe "routing" do
    it '/:identity_id to Pools#index' do
      path = identity_pools_path('foocorp')
      path.should == '/foocorp'
      { :get => path }.should route_to(
        :controller => 'pools',
        :action => 'index',
        :identity_id => 'foocorp'
      )
    end
  end
end
