require 'spec_helper'

describe AssociationsController do
  let(:full_name_field) { FactoryGirl.create(:full_name_field) }
  let(:title_field) { FactoryGirl.create(:title_field) }

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
            @author_model = FactoryGirl.create(:model, name: 'Author', label_field: full_name_field,
                fields: [full_name_field],
                owner: @identity)#, :associations=>[{:name=>'books', :type=>'Belongs To', :references=>@book_model.id}])
            @contributing_authors_association = OrderedListAssociation.create(:name=>'Contributing Authors', :code=>'contributing_authors', :references=>@author_model.id)
            @book_model = FactoryGirl.create(:model, name: 'Book', owner: @identity, :associations => [@contributing_authors_association])
            @publisher_model = FactoryGirl.create(:model, name: 'Publisher', label_field: title_field,
                fields: [title_field],
                owner: @identity)

            @author1 = FactoryGirl.create(:node, model: @author_model, pool: pool, data: {full_name_field.id.to_s => 'Agatha Christie'})
            @author2 = FactoryGirl.create(:node, model: @author_model, pool: pool, data: {full_name_field.id.to_s => 'Raymond Chandler'})
            @publisher = FactoryGirl.create(:node, model: @publisher_model, pool: pool, data: {title_field.id.to_s => 'Simon & Schuster Ltd.'})
            @file = FactoryGirl.create(:node, model: Model.file_entity, pool: pool, data: {})
            @book = FactoryGirl.create(:node, model: @book_model, pool: pool, 
                    :associations=>{@contributing_authors_association.id.to_s=>[@author1.persistent_id, @author2.persistent_id], 'undefined'=>[@publisher.persistent_id], 'files'=>[@file.persistent_id]})
          end
          it "should be successful" do
            get :index, :node_id=>@book.persistent_id, :format=>:json
            response.should be_success
            json = JSON.parse(response.body)
            json.keys.should == ['Contributing Authors', 'undefined', 'files']
            json['Contributing Authors'].should == [{"id"=>@author1.persistent_id,
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
          it "should support requests for incoming associations" do
            get :index, :node_id=>@author1.persistent_id, :format=>:json, filter: "incoming"
            response.should be_success
            json = JSON.parse(response.body)
            json["incoming"].first["persistent_id"].should == @book.persistent_id
            @book.as_json.keys.select {|k| (k != "created_at") && (k != "updated_at")}.each do |key|
              expected = @book.as_json[key]
              expected.stringify_keys! if expected.instance_of? Hash
              json["incoming"].first[key].should ==  @book.as_json[key]
            end

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
                fields_attributes: [{"name"=>"Name", "type"=>"TextField", "uri"=>"dc:description", "code"=>"full_name"}],
                owner: @identity)#, :associations=>[{:name=>'books', :type=>'Belongs To', :references=>@book_model.id}])
            @book_model = FactoryGirl.create(:model, name: 'Book', owner: @identity, :associations_attributes=>[{:name=>'authors', :references=>@author_model.id}])
            @publisher_model = FactoryGirl.create(:model, name: 'Publisher', label: 'name',
                fields_attributes: [{"name"=>"Name", "type"=>"TextField", "uri"=>"dc:description", "code"=>"name"}],
                owner: @identity)

            @author1 = FactoryGirl.create(:node, model: @author_model, pool: pool, data: {full_name_field.id.to_s => 'Agatha Christie'})
            @author2 = FactoryGirl.create(:node, model: @author_model, pool: pool, data: {full_name_field.id.to_s => 'Raymond Chandler'})
            @author3 = FactoryGirl.create(:node, model: @author_model, pool: pool, data: {full_name_field.id.to_s => 'Mark Twain'})
            @publisher = FactoryGirl.create(:node, model: @publisher_model, pool: pool, data: {title_field.id.to_s => 'Simon & Schuster Ltd.'})
            @book = FactoryGirl.create(:node, model: @book_model, pool: pool, 
                    :associations=>{'authors'=>[@author1.persistent_id, @author2.persistent_id], 'undefined'=>[@publisher.persistent_id]})
          end
          it "should be very successful" do
            post :create, :node_id=>@book.persistent_id, :association=> {:code=>'authors', :target_id=>@author3.persistent_id}
            response.should be_success
            @book.latest_version.associations['authors'].should == [@author1.persistent_id, @author2.persistent_id, @author3.persistent_id]
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
          @my_model.associations.count.should == 0
          post :create, :model_id=>@my_model.id, :association=>{name: 'talks', references: @associated_model.id}
          @my_model.reload.associations.count.should == 1
          @my_model.associations.first.name.should == "talks"
          response.should redirect_to edit_model_path(@my_model)
        end
        it "should not redirect when json" do
          @my_model.associations.count.should == 0
          post :create, :model_id=>@my_model.id, :association=>{name: 'talks', references: @associated_model.id}, :format=>:json
          @my_model.reload.associations.count.should == 1
          @my_model.associations.first.name.should == "talks"
          response.should be_successful
        end
      end
    end
  end

end
