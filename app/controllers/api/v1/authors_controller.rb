class Api::V1::AuthorsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_librarian!, only: [:create, :update, :destroy]
  
  def index
    authors = Author.active
    render json: authors, status: :ok
  end

  def create
    author = Author.new(author_params)
    if author.save
      render json: author, status: :created
    else
      render json: { errors: author.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    author = Author.find(params[:id])
    if author.update(author_params)
      render json: author, status: :ok
    else
      render json: { errors: author.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    author = Author.find(params[:id])
    if author.deactivate
      head :no_content
    else
      render json: { errors: "Failed to delete author" }, status: :unprocessable_entity
    end
  end

  private

  def author_params
    params.require(:author).permit(:name)
  end
end