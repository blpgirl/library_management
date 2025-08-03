class DashboardService
  def self.librarian_data
    total_books = Book.where(is_active: true).count
    total_borrowed_books = Borrowing.active.count
    books_due_today = Borrowing.active.where(due_date: Date.today.all_day).count
    overdue_borrowings = Borrowing.overdue.includes(:user, :book)

    {
      total_books: total_books,
      total_borrowed_books: total_borrowed_books,
      books_due_today: books_due_today,
      overdue_borrowings: overdue_borrowings.map do |borrowing|
        {
          user_name: borrowing.user.name,
          book_title: borrowing.book.title,
          due_date: borrowing.due_date.strftime("%b %d, %Y")
        }
      end
    }
  end

  def self.member_data(user)
    borrowed_books = user.borrowings.active.includes(:book)
    overdue_books = borrowed_books.select { |b| b.due_date < Date.today }

    {
      borrowed_books: borrowed_books.map do |borrowing|
        {
          title: borrowing.book.title,
          author: borrowing.book.author.name,
          due_date: borrowing.due_date.strftime("%b %d, %Y")
        }
      end,
      overdue_books: overdue_books.map do |borrowing|
        {
          title: borrowing.book.title,
          author: borrowing.book.author.name,
          due_date: borrowing.due_date.strftime("%b %d, %Y")
        }
      end
    }
  end
end