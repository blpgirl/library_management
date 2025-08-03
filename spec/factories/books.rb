FactoryBot.define do
  factory :book do
    sequence(:title) { |n| "Book #{Faker::Name.unique.name} #{n}" }
    sequence(:isbn) { |n| "978-3-16-148410-#{n}" }
    total_copies { rand(1..20) }
    available_copies { total_copies }
    association :author, factory: :author
    association :genre, factory: :genre
    is_active { true }

    factory :inactive_book do
      is_active { false }
    end
  end
end
