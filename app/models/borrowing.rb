class Borrowing < ApplicationRecord
  # A borrowing belongs to a user and a book.
  belongs_to :user
  belongs_to :book
  
  # Scopes to filter borrowings
  scope :unreturned, -> { where(returned_at: nil) }
  scope :active, -> { where(returned_at: nil, is_canceled: false) }
  scope :overdue, -> { active.where("due_date < ?", Date.today) }

  # Validations
  validate :user_is_not_borrowing_book_already, on: :create
  validate :user_is_active?
  validate :book_is_active?
  validates :borrowed_at, presence: true  
  validates :due_date, presence: true
  validate :due_date_cannot_be_in_the_past

  # Custom validation methods
  def user_is_active?
    errors.add(:user, "is not active") unless user&.is_active
  end

  def book_is_active?
    errors.add(:book, "is not active") unless book&.is_active
  end

  # Check if the book has been returned.
  def returned?
    returned_at.present?
  end
  
  # Check if the book has not been returned.
  def unreturned?
    !returned?
  end

  # other validations and methods

  private

  def due_date_cannot_be_in_the_past
    if due_date.present? && due_date < Date.today
      errors.add(:due_date, "can't be in the past")
    end
  end

  def user_is_not_borrowing_book_already
    if user.borrowings.unreturned.exists?(book_id: book_id)
      errors.add(:user_id, "User has already borrowed this book.")
    end
  end

end
