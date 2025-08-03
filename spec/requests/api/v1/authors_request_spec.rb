# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Authors', type: :request do
  # Using let! is correct for creating the test data
  let!(:librarian_role) { create(:role, name: 'librarian') }
  let!(:member_role) { create(:role, name: 'member') }
  let!(:librarian) { create(:user, role: librarian_role, is_active: true, email: 'librarian@example.com', password: 'password123') }
  let!(:member) { create(:user, role: member_role, is_active: true, email: 'member@example.com', password: 'password123') }
  let!(:active_authors) { create_list(:author, 3, is_active: true) }
  let!(:inactive_author) { create(:author, is_active: false) }

  # The helper to generate authentication headers is correct.
  def auth_headers(user)
    token = JsonWebToken.encode({ user_id: user.id })
    {
      'Authorization' => "Bearer #{token}",
      'Content-Type' => 'application/json',
      'Accept' => 'application/json'
    }
  end
  
  # This before block is crucial for ensuring the test environment uses the
  # correct secret key for JWT. This key must match the one used in production
  # and the one configured in Devise-JWT.
  before do
    # This simulates setting the credential value for tests.
    Rails.application.credentials.devise_jwt_secret_key = 'test_secret'
    # Clear any previous JWT denylist to ensure a clean state
    JwtDenylist.destroy_all
  end

  describe 'GET /api/v1/authors' do
    context 'when a librarian is authenticated' do
      # Note: Removed the before block to simplify, since the `let!` already sets up the data
      # The `get` request is now done directly inside the test.
      it 'returns a list of all active authors' do
        get api_v1_authors_path, headers: auth_headers(librarian)
        expect(response).to have_http_status(:ok)
        expect(json_response.count).to eq(Author.where(is_active: true).count)
      end
    end

    context 'when a member is authenticated' do
      it 'returns a forbidden status' do
        get api_v1_authors_path, headers: auth_headers(member)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end