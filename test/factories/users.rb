FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { "password" }
    auth_token { nil }
    is_admin { false }

    factory :admin do
      is_admin { true }
    end
  end
end