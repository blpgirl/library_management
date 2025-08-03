class Api::V1::BooksController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_librarian!, only: [:create, :update, :destroy]

  def index
    # Search functionality by title, author, or genre.
    # Only active books are shown.
    if params[:query].present?
      books = Book.joins(:author, :genre).where("books.title ILIKE ? OR authors.name ILIKE ? OR genres.name ILIKE ?", "%#{params[:query]}%", "%#{params[:query]}%", "%#{params[:query]}%").where(is_active: true)
    else
      books = Book.where(is_active: true)
    end
    render json: books, status: :ok
  end

  def show
    book = Book.find(params[:id])
    render json: book, status: :ok
  end

  def create
    book = Book.new(book_params)
    if book.save
      render json: book, status: :created
    else
      render json: { errors: book.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    book = Book.find(params[:id])
    if book.update(book_params)
      render json: book, status: :ok
    else
      render json: { errors: book.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    book = Book.find(params[:id])
    # Soft delete the book instead of destroying it.
    if book.update(is_active: false)
      head :no_content
    else
      render json: { errors: "Failed to delete book" }, status: :unprocessable_entity
    end
  end

  private

  def book_params
    params.require(:book).permit(:title, :author_id, :genre_id, :isbn, :total_copies, :is_active)
  end
end