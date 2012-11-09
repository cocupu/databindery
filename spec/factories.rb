FactoryGirl.define do
  factory :login, class: LoginCredential, aliases: [:login_credential] do
    sequence :email do |n|
      "person#{n}@cocupu.com"
    end
    password 'notblank'
  end
  
  factory :identity, aliases: [:owner] do
    sequence :short_name do |n|
      "person#{n}"
    end
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
    sequence :short_name do |n|
      "factory-pool_#{n}"
    end

    owner

    # user_with_posts will create post data after the user has been created
    factory :pool_with_models do
      # posts_count is declared as an ignored attribute and available in
      # attributes on the factory, as well as the callback via the evaluator
      ignore do
        posts_count 5
      end

      # the after(:create) yields two values; the user instance itself and the
      # evaluator, which stores all values from the factory, including ignored
      # attributes; `create_list`'s second argument is the number of records
      # to create and we make sure the user is associated properly to the post
      after(:create) do |pool, evaluator|
        FactoryGirl.create_list(:model, evaluator.posts_count, owner: pool.owner, pool: pool)
      end
    end

  end

  factory :model do
    pool
    sequence :name do |n|
      "Factory model name #{n}"
    end
    fields [{"name"=>"Description", "type"=>"Text Field", "uri"=>"dc:description", "code"=>"description"}.with_indifferent_access]
    owner
  end

  factory :spreadsheet, :class=>Bindery::Spreadsheet do
    owner

  end

  factory :mapping_template do
    owner
    pool
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
