# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :audience do
    pool_id 1
    name "MyString"
    description "MyText"
    order 1
    audience_type_id 1
  end
end
