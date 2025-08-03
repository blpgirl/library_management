require 'rails_helper'

RSpec.describe "Api::V1::Users", type: :request do
  describe "POST /register" do
    let(:user_params) { { user: { name: "New User", email: "newuser@example.com", password: "password", password_confirmation: "password" } } }
    let!(:member_role) { create(:member_role) }

    it "creates a new user and returns a success message" do
      expect {
        post "/register", params: user_params
      }.to change(User, :count).by(1)
      expect(response).to have_http_status(:created)
      expect(json_response['message']).to eq("User registered successfully.")
    end

    it "returns errors for invalid user data" do
      post "/register", params: { user: { email: "invalid-email" } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response['errors']).to include("Email is invalid")
    end
  end
end