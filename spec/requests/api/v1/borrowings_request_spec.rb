# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Borrowings', type: :request do
  let!(:librarian_role) { create(:role, name: 'librarian') }
  let!(:member_role) { create(:role, name: 'member') }
  let!(:librarian) { create(:user, role: librarian_role, is_active: true) }
  let!(:member) { create(:user, role: member_role, is_active: true) }

  def auth_headers(user)
    token = JsonWebToken.encode(user_id: user.id)
    { 'Authorization' => "Bearer #{token}" }
  end
  
  def json_response
    JSON.parse(response.body)
  end

  describe 'GET /api/v1/borrowings' do
    let!(:borrowings) { create_list(:borrowing, 5) }
    
    context 'when a librarian is authenticated' do
      before { get api_v1_borrowings_path, headers: auth_headers(librarian) }
      
      it 'returns a list of all borrowings' do
        expect(response).to have_http_status(:ok)
        expect(json_response.count).to eq(Borrowing.count)
      end
    end
    
    context 'when a member is authenticated' do
      before { get api_v1_borrowings_path, headers: auth_headers(member) }
      
      it 'returns a forbidden status' do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'POST /api/v1/borrowings' do
    let!(:available_book) { create(:book, available_copies: 5) }
    let!(:unavailable_book) { create(:book, available_copies: 0) }
    let!(:inactive_book) { create(:book, is_active: false) }
    
    let(:valid_params) { { borrowing: { book_id: available_book.id } } }
    let(:unavailable_params) { { borrowing: { book_id: unavailable_book.id } } }
    let(:inactive_params) { { borrowing: { book_id: inactive_book.id } } }
    
    context 'when an active member is authenticated' do
      it 'creates a new borrowing for an available book' do
        expect {
          post api_v1_borrowings_path, params: valid_params, headers: auth_headers(member)
        }.to change(Borrowing, :count).by(1)
        expect(response).to have_http_status(:created)
      end
      
      it 'returns an error for an unavailable book' do
        post api_v1_borrowings_path, params: unavailable_params, headers: auth_headers(member)
        expect(response).to have_http_status(:unprocessable_entity)
      end
      
      it 'returns an error for an inactive book' do
        post api_v1_borrowings_path, params: inactive_params, headers: auth_headers(member)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
    
    context 'when an inactive member is authenticated' do
      let!(:inactive_member) { create(:user, is_active: false, role: member_role) }
      
      it 'returns an error for an inactive user' do
        post api_v1_borrowings_path, params: valid_params, headers: auth_headers(inactive_member)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
    
    context 'when a librarian is authenticated' do
      it 'returns a forbidden status' do
        post api_v1_borrowings_path, params: valid_params, headers: auth_headers(librarian)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
