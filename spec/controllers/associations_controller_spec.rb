require 'spec_helper'

describe AssociationsController do
  before do
    @user = FactoryGirl.create :login
  end
  describe "For nodes" do
    describe "index" do
      describe "when not logged on" do
        it "should redirect to root" do
          @book = FactoryGirl.create(:node)
          get :index, :node_id=>@book.id 
          response.should redirect_to root_path
        end
      end

      describe "when logged on" do
        before do
          sign_in @user
        end
        it "should redirect on a model that's not mine " do
          @not_my_node = FactoryGirl.create(:node)
          get :index, :node_id=>@not_my_node.id 
          response.should redirect_to root_path
        end
        describe "on a model that is mine" do
          before do
            owner = @user.identities.first
            pool = owner.pools.first
            @book_model = FactoryGirl.create(:model, name: 'Book', owner: owner, :associations=>[{:name=>'authors', :type=>'Ordered List'}])
            @author_model = FactoryGirl.create(:model, name: 'Author', label: 'full_name', 
                fields: [{"name"=>"Name", "type"=>"Text Field", "uri"=>"dc:description", "code"=>"full_name"}.with_indifferent_access],
                owner: owner, :associations=>[{:name=>'books', :type=>'Belongs To'}])
            @publisher_model = FactoryGirl.create(:model, name: 'Publisher', label: 'name', 
                fields: [{"name"=>"Name", "type"=>"Text Field", "uri"=>"dc:description", "code"=>"name"}.with_indifferent_access],
                owner: owner)

            @author1 = FactoryGirl.create(:node, model: @author_model, pool: pool, data: {'full_name' => 'Agatha Christie'})
            @author2 = FactoryGirl.create(:node, model: @author_model, pool: pool, data: {'full_name' => 'Raymond Chandler'})
            @publisher = FactoryGirl.create(:node, model: @publisher_model, pool: pool, data: {'name' => 'Simon & Schuster Ltd.'})
            @book = FactoryGirl.create(:node, model: @book_model, pool: pool, 
                    :associations=>{'authors'=>[@author1.id, @author2.id], 'undefined'=>[@publisher.id]})
          end
          it "should be successful" do
            get :index, :node_id=>@book.id, :format=>:json
            response.should be_success
            json = JSON.parse(response.body)
            json.keys.should == ['authors', 'undefined']
            json['authors'].should == [{"id"=>@author1.id,
                "persistent_id"=>@author1.persistent_id,
                "title"=>"Agatha Christie"},
               {"id"=>@author2.id,
                "persistent_id"=>@author2.persistent_id,
                "title"=>"Raymond Chandler"}]
            json['undefined'].should == [{'id'=>@publisher.id, "persistent_id"=>@publisher.persistent_id,
                "title"=>'Simon & Schuster Ltd.'}]
          end
        end
      end
    end
  end
  describe "for models" do
    before do
      @my_model = FactoryGirl.create(:model, owner: @user.identities.first)
      @associated_model = FactoryGirl.create(:model, owner: @user.identities.first)
      @not_my_model = FactoryGirl.create(:model)
    end
    describe "create" do
      describe "when not logged on" do
        it "should redirect to root" do
          post :create, :model_id=>@my_model.id 
          response.should redirect_to root_path
        end
      end

      describe "when logged on" do
        before do
          sign_in @user
        end
        it "should redirect on a model that's not mine " do
          post :create, :model_id=>@not_my_model.id 
          response.should redirect_to root_path
        end
        it "should be successful" do
          post :create, :model_id=>@my_model.id, :association=>{type: 'Has One', name: 'talks', references: @associated_model.id}
          @my_model.reload.associations.should == 
             [{"type" => 'Has One', "name"=>"talks", "references" => @associated_model.id.to_s}]
          response.should redirect_to edit_model_path(@my_model)
        end
      end
    end
  end

end
