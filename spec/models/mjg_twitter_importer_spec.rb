require 'spec_helper'

describe MjgTwitterImporter do
  before do
    @filepath = "spec/fixtures/GNIP JSON/gnip_export_sample-20131215.json"
    @single_record_filepath = "spec/fixtures/GNIP JSON/gnip_record-41288.json"
    @simplified_single_record =  "spec/fixtures/GNIP JSON/simplified_single_record.json"
    @pool = FactoryGirl.create(:pool)
    @model = FactoryGirl.create(:model)
  end
  subject {MjgTwitterImporter.new(@pool, @model, @filepath)}

  describe "spawn" do
    before do
      @single_row_json = JSON.parse(File.read(@single_record_filepath))
      @single_row_row_content = subject.flatten(@single_row_json)
    end
    it "should queue a reify job for each object in the json"  do
      Bindery::ReifyHashJob.should_receive(:create).exactly(96).times
      subject.filepath = @filepath
      subject.spawn
    end
    it "should create reify jobs properly" do
      row_content = @single_row_row_content
      Bindery::ReifyHashJob.should_receive(:create).with(pool:@pool.id, source_node:File.basename(@single_record_filepath), model:@model.id, row_index:0, row_content:row_content)
      subject.spawn(@single_record_filepath)
    end
    it "should create model if none provided" do
      row_content = @single_row_row_content
      subject = MjgTwitterImporter.new(@pool, nil, @single_record_filepath)
      subject.should_receive(:generate_model).with(row_content).and_return(@model)
      Bindery::ReifyHashJob.should_receive(:create).with(pool:@pool.id, source_node:File.basename(@single_record_filepath), model:@model.id, row_index:0, row_content:row_content)
      subject.spawn(@single_record_filepath)
    end
  end

  describe "generate_model" do
    it "should create a new model with fields based on the given json" do
      subject.should_receive(:generate_model_fields).and_return([{"sample"=>"field config"}])
      model = subject.generate_model({})
      model.should be_new_record
      model.pool.should == @pool
      model.owner.should == @pool.owner
      model.name.should == "Model for gnip_export_sample-20131215.json"
      model.fields.should == [{"sample"=>"field config"}]
      model.save.should be_true
    end
  end

  describe "generate_model_fields" do
    it "should generate fields for a model based on the given json" do
      subject.filepath = @simplified_single_record
      json = JSON.parse(File.read(@simplified_single_record))
      row_content = subject.flatten(json)
      subject.generate_model_fields(row_content).should == [{"code"=>"id", "name"=>"Id"}, {"code"=>"objectType", "name"=>"Object type"}, {"code"=>"actor_objectType", "name"=>"Actor object type"}, {"code"=>"actor_id", "name"=>"Actor"}]
    end
  end
  
  describe "flatten" do
    it "should flatten the json" do
      json = JSON.parse( File.read(@single_record_filepath) )
      row_content = subject.flatten(json)
      row_content["id"].should == "tag:search.twitter.com,2005:412009176064217088"
      row_content["actor_id"].should == "id:twitter.com:356118825"
      row_content["actor_friendsCount"].should == 3318
      row_content["actor_followersCount"].should == 4451
      row_content["object_twitter_entities_urls_0_expanded_url"].should == "http://liveplaylist.net/playsnow/html5.php?pf=tw&vid=fc8B-zUfL6k&img=http%3A%2F%2Fi.ytimg.com%2Fvi%2Ffc8B-zUfL6k%2Fsddefault.jpg&t=%E6%9A%B4%E8%B5%B0%E6%97%8F%E3%81%8C%E9%82%AA%E9%AD%94%E3%81%A0%E3%81%A3%E3%81%9F%E3%81%AE%E3%81%A7%E8%BB%8A%E3%81%A7%E3%81%B2%E3%81%8D%E9%80%83%E3%81%92%E3%81%97%E3%81%9F%E7%B5%90%E6%9E%9C%EF%BD%97"
      row_content["retweetCount"].should == 1
    end
  end
end
