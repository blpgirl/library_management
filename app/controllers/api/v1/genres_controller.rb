class Api::V1::GenresController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_librarian!, only: [:create, :update, :destroy]
  
  def index
    genres = Genre.active
    render json: genres, status: :ok
  end

  def create
    genre = Genre.new(genre_params)
    if genre.save
      render json: genre, status: :created
    else
      render json: { errors: genre.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    genre = Genre.find(params[:id])
    if genre.update(genre_params)
      render json: genre, status: :ok
    else
      render json: { errors: genre.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    genre = Genre.find(params[:id])
    if genre.deactivate
      head :no_content
    else
      render json: { errors: "Failed to delete genre" }, status: :unprocessable_entity
    end
  end

  private

  def genre_params
    params.require(:genre).permit(:name)
  end
end