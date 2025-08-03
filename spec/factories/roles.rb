FactoryBot.define do
  factory :role do
    sequence(:name) { |n| "role_#{n}" }
    is_active { true }
  end
  
  factory :librarian_role, parent: :role do
    name { 'librarian' }
  end

  factory :member_role, parent: :role do
    name { 'member' }
  end
end
