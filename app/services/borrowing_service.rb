# This service object encapsulates all business logic for borrowing actions.
# It acts as the single source of truth for all borrowing rules and
# orchestrates the automatic updates to the Book model.
class BorrowingService
  # Returns a new BorrowingService instance.
  def self.call
    new
  end

  # Creates a new borrowing record. This method includes all the
  # business logic for a successful borrowing transaction, including
  # the automatic decrement of available copies.
  #
  # @param user [User] The user who is borrowing the book.
  # @param book [Book] The book being borrowed.
  # @return [Borrowing, false] The new borrowing object on success, false on failure.
  def borrow_book(user:, book:)
    # Perform all pre-creation checks here.
    return false unless user.is_active
    return false unless book.is_active
    return false unless book.available_copies > 0
    return false if user_has_unreturned_copy?(user: user, book: book)

    # All checks passed, perform the atomic transaction.
    begin
      Borrowing.transaction do
        borrowing = Borrowing.create!(
          user: user,
          book: book,
          borrowed_at: Time.current,
          due_date: Time.current + 2.weeks
        )
        # The automatic part: decrement available copies as part of the transaction.
        book.decrement!(:available_copies)
        borrowing
      end
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error("Borrowing creation failed: #{e.message}")
      false
    end
  end
  
  # Marks a borrowing as returned and increments the book's available copies.
  #
  # @param borrowing [Borrowing] The borrowing record to update.
  # @return [true, false] True on success, false on failure.
  def return_book(borrowing:)
    return false unless borrowing.unreturned? && !borrowing.is_canceled?

    # Both updates now happen explicitly in this service method and within one transaction.
    begin
      Borrowing.transaction do
        borrowing.update!(returned_at: Time.current)
        borrowing.book.increment!(:available_copies)
      end
      true
    rescue ActiveRecord::RecordInvalid => e
      false
    end
  end

  # Marks a borrowing as canceled (a soft delete) and increments the book's available copies.
  #
  # @param borrowing [Borrowing] The borrowing record to update.
  # @return [true, false] True on success, false on failure.
  def cancel_borrowing(borrowing:)
    # Only allow cancellation if the book has not been returned and the borrowing is not already canceled.
    return false unless borrowing.unreturned? && !borrowing.is_canceled
    
    # Perform both updates in a single, atomic database transaction.
    begin
      Borrowing.transaction do
        borrowing.update!(is_canceled: true)
        borrowing.book.increment!(:available_copies)
      end
      true
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error("Borrowing cancellation failed: #{e.message}")
      false
    end
  end

  private

  def user_has_unreturned_copy?(user:, book:)
    Borrowing.active.where(user: user, book: book).exists?
  end
end