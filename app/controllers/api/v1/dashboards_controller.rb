class Api::V1::DashboardsController < ApplicationController
  before_action :authenticate_user!

  def librarian
    authorize_librarian!
    data = DashboardService.librarian_data
    render json: data, status: :ok
  end

  def member
    authorize_member!
    data = DashboardService.member_data(current_user)
    render json: data, status: :ok
  end
end