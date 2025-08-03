class BorrowingSerializer < ActiveModel::Serializer
  attributes :id, :borrowed_at, :due_date, :returned_at, :book_id, :user_id, :is_canceled
end