FactoryGirl.define do
  factory :login, class: LoginCredential, aliases: [:login_credential] do
    sequence :email do |n|
      "person#{n}@cocupu.com"
    end
    password 'notblank'
  end
  
  factory :identity, aliases: [:owner] do
    login_credential
  end

  factory :exhibit do
    pool
  end

  factory :node do
    pool
    model
  end

  factory :pool do
    owner
  end

  factory :model do
    sequence :name do |n|
      "Factory model name  #{n}"
    end
    owner
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
