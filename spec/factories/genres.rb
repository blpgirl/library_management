FactoryBot.define do  
  factory :genre do
    sequence(:name) { |n| "Genre #{n}" }
  end
  
  factory :active_genre, parent: :genre do
    is_active { true }
  end

  factory :inactive_genre, parent: :genre do
    is_active { false }
  end
end
