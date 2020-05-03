FactoryBot.define do
  factory :user do
    sequence(:username) { |i| "User #{i}" }
    sequence(:email) { |i| "user-#{i}@chotto-jigsaw.test" }
    sequence(:password) { |i| "password-#{i}" }
  end
end
