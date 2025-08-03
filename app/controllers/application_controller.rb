class ApplicationController < ActionController::API
  # This Devise method will handle the JWT authentication for every request.
  # It checks for a valid token in the Authorization header.
  # If a token is present and valid, it will set `current_user`.
  # If no token is present or it's invalid, it will return a 401 Unauthorized response.
  before_action :authenticate_user!

  private

  def authorize_librarian!
    render json: { errors: "Forbidden" }, status: :forbidden unless current_user&.librarian?
  end

  def authorize_member!
    render json: { errors: "Forbidden" }, status: :forbidden unless current_user&.member?
  end
end