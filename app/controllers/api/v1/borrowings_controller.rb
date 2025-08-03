class Api::V1::BorrowingsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_member!, only: [:create]
  before_action :authorize_librarian!, only: [:update, :index, :cancel]

  def index
    # Only librarians can see all borrowings.
    borrowings = Borrowing.all
    render json: borrowings, status: :ok
  end

  def create
    # Member can borrow a book.
    book = Book.find(params[:book_id])
    result = BookManagerService.borrow_book(current_user, book)

    if result[:success]
      render json: result[:borrowing], status: :created
    else
      render json: { errors: result[:message] }, status: :unprocessable_entity
    end
  end

  def update
    # Librarian can mark a book as returned.
    borrowing = Borrowing.find(params[:id])
    result = BookManagerService.return_book(borrowing)

    if result[:success]
      render json: result[:borrowing], status: :ok
    else
      render json: { errors: result[:message] }, status: :unprocessable_entity
    end
  end
  
  def cancel
    # Librarian can cancel a borrowing.
    borrowing = Borrowing.find(params[:id])
    result = BookManagerService.cancel_borrowing(borrowing)
    
    if result[:success]
      render json: result[:borrowing], status: :ok
    else
      render json: { errors: result[:message] }, status: :unprocessable_entity
    end
  end
end
