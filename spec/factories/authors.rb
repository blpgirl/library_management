FactoryBot.define do
  factory :author do
    sequence(:name) { |n| "Author #{Faker::Name.unique.name} #{n}" }
  end
  
  factory :active_author, parent: :author do
    is_active { true }
  end

  factory :inactive_author, parent: :author do
    is_active { false }
  end
end
