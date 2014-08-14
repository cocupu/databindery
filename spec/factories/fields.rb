# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :field do
    name "MyString"
    type "TextField"
    uri "MyString"
    code "MyString"
    label "MyString"
  end
  factory :model_name_field, class:Field do
    name "model_name"
  end
  factory :model_field, class:IntegerField do
    name "model"
  end
  factory :subject_field, class:TextField do
    name "subject"
  end
  factory :location_field, class:Field do
    name "location"
  end
  factory :access_level_field, class:Field do
    name "access_level"
  end
  factory :text_area_field, class:TextArea do
    name "notes"
  end
  factory :date_field, class:DateField do
    name "important_date"
  end
  factory :integer_field, class:IntegerField do
    name "a_number"
  end
end
