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
    @model2.fields = [{code: 'style', name: 'Style'}, {code: 'label', name: "Label"}, {code: 'f2', name: "Another one"}]

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
        assigns[:exhibits].should_not include @exhibit2
      end
    end

    describe "new" do
      it "should be success" do
        get :new, :pool_id=>@pool, :identity_id=>@identity.short_name
        response.should be_successful
        assigns[:exhibit].should be_kind_of Exhibit
        assigns[:fields].should == [{'code' => 'f2', 'name'=> "Another one"}, {'code' => 'f1', 'name'=> 'Field good'}, {'code' => 'label', 'name'=> "Label"}, {'code' => 'style', 'name'=> 'Style'} ]
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
        assigns[:fields].should == [{'code' => 'f2', 'name'=> "Another one"}, {'code' => 'f1', 'name'=> 'Field good'}, {'code' => 'label', 'name'=> "Label"}, {'code' => 'style', 'name'=> 'Style'} ]
      end
    end

    describe "update" do
      it "should be success" do
        put :update, :id=>@exhibit.id, :exhibit=> {:title => 'Foresooth', :facets=>['looketh', 'overmany', 'thither'], :index_fields=>['title', 'author', 'call_number'] }, :pool_id=>@pool, :identity_id=>@identity.short_name
        response.should redirect_to identity_pool_exhibit_path(@identity.short_name, @pool, assigns[:exhibit])
        assigns[:exhibit].facets.should == ['looketh', 'overmany', 'thither']
        assigns[:exhibit].index_fields.should == ['title', 'author', 'call_number']
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
