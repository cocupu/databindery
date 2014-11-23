require 'spec_helper'

describe Node do
  let(:identity) { FactoryGirl.create :identity }
  let(:pool){ FactoryGirl.create :pool, :owner=>identity }
  let(:first_name_field) { FactoryGirl.create :first_name_field }
  let(:last_name_field) { FactoryGirl.create :last_name_field }
  let(:title_field) { FactoryGirl.create :title_field }
  let(:model) do
    FactoryGirl.create(:model,
                       fields: [first_name_field,last_name_field],
                       label_field: last_name_field,
                       associations_attributes: [{name: 'authors', references: ref.id}])
  end
  let(:ref) do
    FactoryGirl.create(:model,
                       fields: [first_name_field, last_name_field, title_field],
                       label_field: last_name_field)
  end

  before do
    subject.model = model
  end

  it "should create a new version when it's changed" do
    subject.pool = pool
    subject.save!
    subject.update_attributes(:data=>{'boo'=>'bap'})
    all_versions = Node.where(persistent_id: subject.persistent_id).to_a
    all_versions.length.should == 2
  end

  it "should get the latest version" do
    subject.pool = pool
    subject.save!
    subject.attributes = {:data=>{'boo'=>'bap'}}
    new_subject = subject.update

    Node.latest_version(subject.persistent_id).should == new_subject
  end

end
