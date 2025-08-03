require 'rails_helper'

RSpec.describe "Users::Sessions", type: :request do
  let!(:member_role) { create(:member_role) }
  let!(:user) { create(:user, role: member_role, password: 'password') }
  let(:valid_credentials) { { user: { email: user.email, password: 'password' } } }
  let(:invalid_credentials) { { user: { email: user.email, password: 'wrongpassword' } } }

  describe "POST /login" do
    context "with valid credentials" do
      it "returns a success response and a JWT token" do
        post '/login', params: valid_credentials
        expect(response).to have_http_status(:ok)
        expect(json_response['status']['message']).to eq('Logged in successfully.')
        expect(response.headers['Authorization']).to be_present
      end
    end

    context "with invalid credentials" do
      it "returns an unauthorized response" do
        post '/login', params: invalid_credentials
        expect(response).to have_http_status(:unauthorized)
        expect(json_response['error']).to eq("Invalid Email or password.")
      end
    end
  end

  describe "DELETE /logout" do
    let!(:token) do
      post '/login', params: valid_credentials
      response.headers['Authorization']
    end
    
    it "returns a success response and revokes the token" do
      delete '/logout', headers: { 'Authorization' => token }
      expect(response).to have_http_status(:ok)
      expect(json_response['status']['message']).to eq('Logged out successfully.')
      
      # Attempt to use the revoked token, should be unauthorized
      get '/api/v1/books', headers: { 'Authorization' => token }
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns an unauthorized response for an invalid token" do
      delete '/logout', headers: { 'Authorization' => 'Bearer invalid_token' }
      expect(response).to have_http_status(:unauthorized)
      expect(json_response['status']['message']).to eq("Couldn't find an active session.")
    end
  end
end