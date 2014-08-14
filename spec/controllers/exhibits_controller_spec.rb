require 'spec_helper'

describe ExhibitsController do
  it "should route" do
    identity_pool_exhibits_path('matt', 'marpa').should == '/matt/marpa/exhibits'
  end

  before do
    @identity = FactoryGirl.create :identity
    @pool = FactoryGirl.create :pool, :owner=>@identity
    @exhibit = FactoryGirl.build(:exhibit, pool: @pool)
    @exhibit.facets = ['f2']
    @exhibit.save!
    @exhibit2 = FactoryGirl.create(:exhibit, :pool=>FactoryGirl.create(:pool, :owner=>@identity)) #should not show this exhibit in index.
    @model1 = FactoryGirl.create(:model, :name=>"Mods and Rockers", :pool=>@exhibit.pool, fields_attributes: [{code: 'f1', name: 'Field good'}, {code: 'f2', name: "Another one"}])
    @model2 = FactoryGirl.create(:model, :pool=>@exhibit.pool, fields_attributes: [{code: 'style', name: 'Style'}, {code: 'label', name: "Label"}, {code: 'f2', name: "Another one"}])
  end

  describe "when signed in" do
    before do
      sign_in @identity.login_credential
    end
    describe "index" do
      it "should be success" do
        get :index, :pool_id=>@pool, :identity_id=>@identity.short_name
        response.should be_successful
        assigns[:pool].should == @pool
        assigns[:exhibits].should ==[@exhibit]
        assigns[:exhibits].should_not include @exhibit2
      end
    end

    describe "new" do
      it "should be success" do
        get :new, :pool_id=>@pool, :identity_id=>@identity.short_name
        response.should be_successful
        assigns[:exhibit].should be_kind_of Exhibit
        assigns[:fields].should == @pool.all_fields
      end
    end

    describe "create" do
      it "should be success" do
        post :create, :pool_id=>@pool, :identity_id=>@identity.short_name, :exhibit=> {:title => 'Foresooth', :facets=>['looketh', 'overmany', 'thither'] }
        response.should redirect_to identity_pool_search_path(@identity, @pool, perspective: assigns[:exhibit])
        assigns[:exhibit].facets.should == ['looketh', 'overmany', 'thither']
      end
      it "should not allow create for a pool you don't own" do
        post :create, pool_id: FactoryGirl.create(:pool), identity_id: @identity.short_name, :exhibit=> {:title => 'Foresooth', :facets=>'looketh, overmany, thither' }
        response.should be_not_found
      end
    end

    describe "edit" do
      it "should be success" do
        get :edit, :id =>@exhibit.id, :pool_id=>@pool, :identity_id=>@identity.short_name
        response.should be_successful
        assigns[:exhibit].should be_kind_of Exhibit
        assigns[:fields].should == @pool.all_fields
      end
    end

    describe "update" do
      it "should be success" do
        put :update, :id=>@exhibit.id, :exhibit=> {:title => 'Foresooth', :facets=>['looketh', 'overmany', 'thither'], :index_fields=>['title', 'author', 'call_number'] }, :pool_id=>@pool, :identity_id=>@identity.short_name
        response.should redirect_to edit_identity_pool_exhibit_path(@identity, @pool, assigns[:exhibit])
        assigns[:exhibit].facets.should == ['looketh', 'overmany', 'thither']
        assigns[:exhibit].index_fields.should == ['title', 'author', 'call_number']
      end
      it "should update filters" do
        exhibit_attributes = {title: "Test Perspective with Model", filters_attributes:[{"field_name"=>"subject", "operator"=>"+", "values"=>["4", "1"]}, {"field_name"=>"collection_owner", "operator"=>"-", "values"=>["Hannah Severin"]}], :pool_id=>@pool, :identity_id=>@identity.short_name}
        put :update, :id=>@exhibit.id, :exhibit=> exhibit_attributes, :pool_id=>@pool, :identity_id=>@identity.short_name
        assigns[:exhibit].filters.count.should == 2
        subject_filter = assigns[:exhibit].filters.where(field_name:"subject").first
        subject_filter.operator.should == "+"
        subject_filter.values.should == ["4", "1"]
        collection_owner_filter = assigns[:exhibit].filters.where(field_name:"collection_owner").first
        collection_owner_filter.operator.should == "-"
        collection_owner_filter.values.should == ["Hannah Severin"]
      end
      it "should not add filters when filters are not fully specified" do
        exhibit_attributes = {title: "Test Perspective with Model", filters_attributes:[{"field_name"=>"model"}, {"field_name"=>"collection_location", "operator"=>"+", "values"=>[""]}], :pool_id=>@pool, :identity_id=>@identity.short_name}
        put :update, :id=>@exhibit.id, :exhibit=> exhibit_attributes, :pool_id=>@pool, :identity_id=>@identity.short_name
        assigns[:exhibit].filters.should == []
      end
      it "should add filters for restricting models when restrict_models is checked" do
        exhibit_attributes = {title: "Test Perspective with Model", restrict_models: "1", filters_attributes:[{"field_name"=>"model", "operator"=>"+", "values"=>["4", "1"]}], :pool_id=>@pool, :identity_id=>@identity.short_name}
        put :update, :id=>@exhibit.id, :exhibit=> exhibit_attributes, :pool_id=>@pool, :identity_id=>@identity.short_name
        assigns[:exhibit].filters.count.should == 1
        assigns[:exhibit].filters.first.field_name.should == "model"
      end
      it "should not restrict models if restrict_models is not checked" do
        exhibit_attributes = {title: "Test Perspective with Model", filters_attributes:[{"field_name"=>"model", "operator"=>"+", "values"=>["foo", "bar"]}], :pool_id=>@pool, :identity_id=>@identity.short_name}
        put :update, :id=>@exhibit.id, :exhibit=> exhibit_attributes, :pool_id=>@pool, :identity_id=>@identity.short_name
        assigns[:exhibit].filters.should == []
      end
    end

  end

  describe "when not signed in" do
    describe "index" do
      it "should be unauthorized" do
        get :index, :pool_id=>@pool, :identity_id=>@identity.short_name
        response.should redirect_to root_path
      end
    end

    describe "new" do
      it "should be unauthorized" do
        get :new, :pool_id=>@pool, :identity_id=>@identity.short_name
        response.should redirect_to root_path
      end
    end

    describe "create" do
      it "should be unauthorized" do
        post :create, :exhibit=> {:title => 'Foresooth', :facets=>'looketh, overmany, thither' }, :pool_id=>@pool, :identity_id=>@identity.short_name
        response.should redirect_to root_path
      end
    end

    describe "edit" do
      it "should be unauthorized" do
        get :edit, :id =>@exhibit.id, :pool_id=>@pool, :identity_id=>@identity.short_name
        response.should redirect_to root_path
      end
    end

    describe "update" do
      it "should be unauthorized" do
        put :update, :id=>@exhibit.id, :exhibit=> {:title => 'Foresooth', :facets=>'looketh, overmany, thither' }, :pool_id=>@pool, :identity_id=>@identity.short_name
        response.should redirect_to root_path
      end
    end

  end


end
