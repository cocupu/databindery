FactoryGirl.define do
  factory :login, :class=>LoginCredential do
    email 'test@cocupu.com'
    password 'notblank'
  end
end
