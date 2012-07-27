FactoryGirl.define do
  factory :login, :class=>LoginCredential do
    sequence :email do |n|
      "person#{n}@cocupu.com"
    end
    password 'notblank'
  end

  factory :spreadsheet, :class=>Cocupu::Spreadsheet do

  end

  factory :worksheet do
    spreadsheet 
    order 0
    after(:create) do |worksheet, evaluator|
      FactoryGirl.create_list(:spreadsheet_row, 5, worksheet: worksheet)
    end
  end

  factory :spreadsheet_row do
    values {  5.times.map { generate(:random_data)} }
  end

  sequence(:random_data) {|n| "#{n}#{rand(1000)}" }

end
