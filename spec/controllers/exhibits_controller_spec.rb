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
    @model1 = FactoryGirl.create(:model, :name=>"Mods and Rockers", :pool=>@exhibit.pool)

    @model1.fields = [{code: 'f1', name: 'Field good'}, {code: 'f2', name: "Another one"}]
    @model1.save!

    @model2 = FactoryGirl.create(:model, :pool=>@exhibit.pool)
    @model2.fields = [{code: 'style', name: 'Style'}, {code: 'label', name: "Label"}]

    #TODO ensure that code is unique for all fields in a pool, so that Author.name is separate from Book.name
    @model2.save!
  end

  describe "when signed in" do
    before do
      sign_in @identity.login_credential
    end
    describe "index" do
      it "should be success" do
        get :index, :pool_id=>@pool, :identity_id=>@identity.short_name
        response.should be_successful
        assigns[:exhibits].should ==[@exhibit]
      end
    end

    describe "new" do
      it "should be success" do
        get :new, :pool_id=>@pool, :identity_id=>@identity.short_name
        response.should be_successful
        assigns[:exhibit].should be_kind_of Exhibit
        assigns[:fields].should == [{'code' => 'style', 'name'=> 'Style'}, {'code' => 'label', 'name'=> "Label"}, {'code' => 'f1', 'name'=> 'Field good'}, {'code' => 'f2', 'name'=> "Another one"}]
      end
    end

    describe "create" do
      it "should be success" do
        post :create, :pool_id=>@pool, :identity_id=>@identity.short_name, :exhibit=> {:title => 'Foresooth', :facets=>['looketh', 'overmany', 'thither'] }
        response.should redirect_to identity_pool_exhibit_path(@identity.short_name, @pool, assigns[:exhibit])
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
        assigns[:fields].should == [{'code' => 'f1', 'name'=> 'Field good'}, {'code' => 'f2', 'name'=> "Another one"}, {'code' => 'style', 'name'=> 'Style'}, {'code' => 'label', 'name'=> "Label"} ]
      end
    end

    describe "update" do
      it "should be success" do
        put :update, :id=>@exhibit.id, :exhibit=> {:title => 'Foresooth', :facets=>['looketh', 'overmany', 'thither'] }, :pool_id=>@pool, :identity_id=>@identity.short_name
        response.should redirect_to identity_pool_exhibit_path(@identity.short_name, @pool, assigns[:exhibit])
        assigns[:exhibit].facets.should == ['looketh', 'overmany', 'thither']
      end
    end

    describe "show" do
      before do
        ## Clear out old results so we start from scratch
        raw_results = Cocupu.solr.get 'select', :params => {:q => '{!lucene}model_name:"Mods and Rockers"', :fl=>'id', :qt=>'document', :qf=>'model', :rows=>100}
        Cocupu.solr.delete_by_id raw_results["response"]["docs"].map{ |d| d["id"]}
        raw_results = Cocupu.solr.get 'select', :params => {:q => 'bazaar', :fl=>'id', :qf=>'field_good_s'}
        Cocupu.solr.delete_by_id raw_results["response"]["docs"].map{ |d| d["id"]}
        Cocupu.solr.commit

        @instance = Node.new(data: {'f1' => 'bazaar'})
        @instance.model = @model1
        @instance.pool = @exhibit.pool 
        @instance.save!

        @instance.data['f2'] = 'Bizarre'
        @instance.save! #Create a new version of this, only one version should show in search results.

        @instance2 = Node.new(data: {'f1' => 'bazaar'})
        @instance2.model = @model1
        @instance2.pool = FactoryGirl.create :pool
        @instance2.save!

      end
      it "should be success" do
        get :show, :id=>@exhibit.id, :q=>'bazaar', :pool_id=>@pool, :identity_id=>@identity.short_name
        assigns[:total].should == 1
        assigns[:results].should_not be_nil
        assigns[:exhibit].should == @exhibit
        assigns[:facet_fields].should == {"f2_facet"=>["Bizarre", 1], "model_name"=>["Mods and Rockers", 1]}
        response.should be_successful
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

    describe "show" do
      it "should be unauthorized" do
        get :show, :id=>@exhibit.id, :q=>'bazaar', :pool_id=>@pool, :identity_id=>@identity.short_name
        response.should redirect_to root_path
      end
    end
  end


end
