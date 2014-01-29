# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :spawn_job do
    reify_jobs "MyText"
    mapping_template nil
    node nil
  end
end
