# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :search_filter do
    field_name "MyString"
    operator "MyString"
    values "MyText"
  end
end
