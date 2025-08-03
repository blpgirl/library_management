class Api::V1::UsersController < ApplicationController
  def create
    member_role = Role.find_by(name: 'member')
    # Removed is_active: true because the Activatable concern and migration default handle it.
    user = User.new(user_params.merge(role: member_role))
    if user.save
      render json: { message: "User registered successfully." }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end