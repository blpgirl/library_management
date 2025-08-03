FactoryBot.define do
  factory :borrowing do
    association :user, factory: :user
    association :book, factory: :book
    borrowed_at { Time.current }
    due_date { 2.weeks.from_now }
    is_canceled { false }

    factory :canceled_borrowing do
      is_canceled { true }
    end
    
    factory :returned_borrowing do
      returned_at { 1.day.ago }
    end
  end
end
