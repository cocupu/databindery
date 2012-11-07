require 'spec_helper'

describe AssociationsController do
  before do
    @identity = FactoryGirl.create :identity
  end
  describe "For nodes" do
    describe "index" do
      describe "when not logged on" do
        it "should redirect to root" do
          @book = FactoryGirl.create(:node)
          get :index, :node_id=>@book.persistent_id 
          response.should redirect_to root_path
        end
      end

      describe "when logged on" do
        before do
          sign_in @identity.login_credential
        end
        it "should redirect on a model that's not mine " do
          @not_my_node = FactoryGirl.create(:node)
          get :index, :node_id=>@not_my_node.persistent_id 
          response.should redirect_to root_path
        end
        describe "on a model that is mine" do
          before do
            pool = FactoryGirl.create :pool, :owner=>@identity
            @author_model = FactoryGirl.create(:model, name: 'Author', label: 'full_name', 
                fields: [{"name"=>"Name", "type"=>"Text Field", "uri"=>"dc:description", "code"=>"full_name"}.with_indifferent_access],
                owner: @identity)#, :associations=>[{:name=>'books', :type=>'Belongs To', :references=>@book_model.id}])
            @book_model = FactoryGirl.create(:model, name: 'Book', owner: @identity, :associations => [{:name=>'authors', :type=>'Ordered List', :references=>@author_model.id}])
            @publisher_model = FactoryGirl.create(:model, name: 'Publisher', label: 'name', 
                fields: [{"name"=>"Name", "type"=>"Text Field", "uri"=>"dc:description", "code"=>"name"}.with_indifferent_access],
                owner: @identity)

            @author1 = FactoryGirl.create(:node, model: @author_model, pool: pool, data: {'full_name' => 'Agatha Christie'})
            @author2 = FactoryGirl.create(:node, model: @author_model, pool: pool, data: {'full_name' => 'Raymond Chandler'})
            @publisher = FactoryGirl.create(:node, model: @publisher_model, pool: pool, data: {'name' => 'Simon & Schuster Ltd.'})
            @file = FactoryGirl.create(:node, model: Model.file_entity, pool: pool, data: {})
            @book = FactoryGirl.create(:node, model: @book_model, pool: pool, 
                    :associations=>{'authors'=>[@author1.persistent_id, @author2.persistent_id], 'undefined'=>[@publisher.persistent_id], 'files'=>[@file.persistent_id]})
          end
          it "should be successful" do
            get :index, :node_id=>@book.persistent_id, :format=>:json
            response.should be_success
            json = JSON.parse(response.body)
            json.keys.should == ['authors', 'undefined', 'files']
            json['authors'].should == [{"id"=>@author1.persistent_id,
                "persistent_id"=>@author1.persistent_id,
                "title"=>"Agatha Christie"},
               {"id"=>@author2.persistent_id,
                "persistent_id"=>@author2.persistent_id,
                "title"=>"Raymond Chandler"}]
            json['undefined'].should == [{'id'=>@publisher.persistent_id, "persistent_id"=>@publisher.persistent_id,
                "title"=>'Simon & Schuster Ltd.'}]
            json['files'].should == [{'id'=>@file.persistent_id, "persistent_id"=>@file.persistent_id,
                "title"=>@file.persistent_id}]
          end
        end
      end
    end
    describe "create" do
      describe "when logged on" do
        before do
          sign_in @identity.login_credential
        end
        it "should redirect on a model that's not mine " do
          @not_my_node = FactoryGirl.create(:node)
          post :create, :node_id=>@not_my_node.persistent_id 
          response.should redirect_to root_path
        end
        describe "on a model that is mine" do
          before do
            pool = FactoryGirl.create :pool, :owner=>@identity
            @author_model = FactoryGirl.create(:model, name: 'Author', label: 'full_name', 
                fields: [{"name"=>"Name", "type"=>"Text Field", "uri"=>"dc:description", "code"=>"full_name"}.with_indifferent_access],
                owner: @identity)#, :associations=>[{:name=>'books', :type=>'Belongs To', :references=>@book_model.id}])
            @book_model = FactoryGirl.create(:model, name: 'Book', owner: @identity, :associations=>[{:name=>'authors', :type=>'Ordered List', :references=>@author_model.id}])
            @publisher_model = FactoryGirl.create(:model, name: 'Publisher', label: 'name', 
                fields: [{"name"=>"Name", "type"=>"Text Field", "uri"=>"dc:description", "code"=>"name"}.with_indifferent_access],
                owner: @identity)

            @author1 = FactoryGirl.create(:node, model: @author_model, pool: pool, data: {'full_name' => 'Agatha Christie'})
            @author2 = FactoryGirl.create(:node, model: @author_model, pool: pool, data: {'full_name' => 'Raymond Chandler'})
            @publisher = FactoryGirl.create(:node, model: @publisher_model, pool: pool, data: {'name' => 'Simon & Schuster Ltd.'})
            @book = FactoryGirl.create(:node, model: @book_model, pool: pool, 
                    :associations=>{'authors'=>[@author1.persistent_id, @author2.persistent_id], 'undefined'=>[@publisher.id]})
          end
          it "should be very successful" do
            post :create, :node_id=>@book.persistent_id, :association=> {:code=>'authors', :target_id=>'5678'}
            response.should be_success
            @book.latest_version.associations['authors'].should == [@author1.persistent_id, @author2.persistent_id, '5678']
          end
        end
      end
    end
  end
  describe "for models" do
    before do
      pool = FactoryGirl.create :pool, :owner=>@identity
      @my_model = FactoryGirl.create(:model, pool: pool)
      @associated_model = FactoryGirl.create(:model, pool: pool)
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
          sign_in @identity.login_credential
        end
        it "should redirect on a model that's not mine " do
          post :create, :model_id=>@not_my_model.id 
          response.should redirect_to root_path
        end
        it "should be successful" do
          post :create, :model_id=>@my_model.id, :association=>{type: 'Has One', name: 'talks', references: @associated_model.id}
          @my_model.reload.associations.should == 
             [{"type" => 'Has One', "name"=>"talks", "references" => @associated_model.id.to_s, "label"=>@associated_model.name, "code"=>'talks'}]
          response.should redirect_to edit_model_path(@my_model)
        end
        it "should not redirect when json" do
          post :create, :model_id=>@my_model.id, :association=>{type: 'Has Many', name: 'talks', references: @associated_model.id}, :format=>:json
          @my_model.reload.associations.should == 
             [{"type" => 'Has Many', "name"=>"talks", "references" => @associated_model.id, "label"=>@associated_model.name, "code"=>'talks'}]
          response.should be_successful 
        end
      end
    end
  end

end
