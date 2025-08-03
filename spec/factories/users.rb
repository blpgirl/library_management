FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "User #{n} #{Faker::Name.unique.name}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    encrypted_password { 'password' }
    association :role, factory: :member_role
    is_active { true }

    factory :librarian do
      association :role, factory: :librarian_role
    end

    factory :member do
      association :role, factory: :member_role
    end
    
    factory :inactive_user do
      is_active { false }
    end
  end
end
