FactoryGirl.define do
  factory :login, :class=>LoginCredential do
    sequence :email do |n|
      "person#{n}@cocupu.com"
    end
    password 'notblank'
  end
end
