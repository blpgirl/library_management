class BookManagerService
  def self.borrow_book(user, book)
    # Check if the book is available and the user is active.
    return { success: false, message: "Book is not available." } if book.available_copies.zero?
    return { success: false, message: "The book is not active." } unless book.is_active
    return { success: false, message: "The user is not active." } unless user.is_active

    if user.borrowings.unreturned.where(book: book).exists?
      return { success: false, message: "You have already borrowed this book." }
    end
    
    borrowing = Borrowing.create(user: user, book: book)
    if borrowing.persisted?
      { success: true, borrowing: borrowing }
    else
      { success: false, message: borrowing.errors.full_messages.to_sentence }
    end
  end

  def self.return_book(borrowing)
    return { success: false, message: "Book has already been returned." } if borrowing.returned?

    if borrowing.update(returned_at: Time.current)
      { success: true, borrowing: borrowing }
    else
      { success: false, message: borrowing.errors.full_messages.to_sentence }
    end
  end
end