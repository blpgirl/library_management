# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Books', type: :request do
  let!(:librarian_role) { create(:role, name: 'librarian') }
  let!(:member_role) { create(:role, name: 'member') }
  let!(:librarian) { create(:user, role: librarian_role, is_active: true) }
  let!(:member) { create(:user, role: member_role, is_active: true) }

  let!(:author) { create(:author) }
  let!(:books) { create_list(:book, 3, is_active: true, author: author) }
  let!(:inactive_book) { create(:book, is_active: false) }
  
  def auth_headers(user)
    token = JsonWebToken.encode(user_id: user.id)
    { 'Authorization' => "Bearer #{token}" }
  end
  
  def json_response
    JSON.parse(response.body)
  end
  
  describe 'GET /api/v1/books' do
    context 'when authenticated' do
      it 'returns all active books for any user' do
        get api_v1_books_path, headers: auth_headers(member)
        expect(response).to have_http_status(:ok)
        expect(json_response.count).to eq(books.count)
      end
      
      it 'returns books based on query by author\'s name' do
        get api_v1_books_path, params: { author_name: author.name }, headers: auth_headers(member)
        expect(response).to have_http_status(:ok)
        expect(json_response.count).to eq(books.count)
      end
    end
    
    context 'when not authenticated' do
      it 'returns an unauthorized status' do
        get api_v1_books_path
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
  
  describe 'GET /api/v1/books/:id' do
    context 'when authenticated' do
      it 'returns the specified book for any user' do
        get api_v1_book_path(books.first), headers: auth_headers(member)
        expect(response).to have_http_status(:ok)
        expect(json_response['title']).to eq(books.first.title)
      end
      
      it 'returns a not found error for an inactive book' do
        get api_v1_book_path(inactive_book), headers: auth_headers(member)
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
