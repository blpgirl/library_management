require 'rails_helper'

RSpec.describe "Api::V1::Genres", type: :request do
  let!(:librarian_role) { create(:librarian_role) }
  let!(:member_role) { create(:member_role) }
  let!(:librarian) { create(:librarian, role: librarian_role) }
  let!(:member) { create(:member, role: member_role) }
  let!(:active_genre) { create(:genre) }
  let!(:inactive_genre) { create(:inactive_genre) }
  
  # Devise JWT authentication tokens
  let(:librarian_token) { Warden::JWTAuth::UserEncoder.new.call(librarian, :user, nil).first }
  let(:member_token) { Warden::JWTAuth::UserEncoder.new.call(member, :user, nil).first }

  describe "GET /api/v1/genres" do
    context "when a librarian is authenticated" do
      it "returns a list of all active genres" do
        get api_v1_genres_path, headers: { 'Authorization' => "Bearer #{librarian_token}" }
        expect(response).to have_http_status(:ok)
        expect(json_response.count).to eq(Genre.where(is_active: true).count)
        expect(json_response.any? { |g| g['id'] == inactive_genre.id }).to be_falsey
      end
    end
    
    context "when a member is authenticated" do
      it "returns a forbidden status" do
        get api_v1_genres_path, headers: { 'Authorization' => "Bearer #{member_token}" }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "POST /api/v1/genres" do
    context "when a librarian is authenticated" do
      it "creates a new genre" do
        genre_params = { genre: { name: "New Genre" } }
        expect {
          post api_v1_genres_path, params: genre_params, headers: { 'Authorization' => "Bearer #{librarian_token}" }
        }.to change(Genre, :count).by(1)
        expect(response).to have_http_status(:created)
      end
    end

    context "when a member is authenticated" do
      it "returns a forbidden status" do
        genre_params = { genre: { name: "New Genre" } }
        post api_v1_genres_path, params: genre_params, headers: { 'Authorization' => "Bearer #{member_token}" }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "PUT /api/v1/genres/:id" do
    let(:new_name) { "Updated Genre Name" }

    context "when a librarian is authenticated" do
      it "updates the genre" do
        put api_v1_genre_path(active_genre), params: { genre: { name: new_name } }, headers: { 'Authorization' => "Bearer #{librarian_token}" }
        active_genre.reload
        expect(response).to have_http_status(:ok)
        expect(active_genre.name).to eq(new_name)
      end
    end

    context "when a member is authenticated" do
      it "returns a forbidden status" do
        put api_v1_genre_path(active_genre), params: { genre: { name: new_name } }, headers: { 'Authorization' => "Bearer #{member_token}" }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "DELETE /api/v1/genres/:id" do
    context "when a librarian is authenticated" do
      it "soft deletes the genre" do
        delete api_v1_genre_path(active_genre), headers: { 'Authorization' => "Bearer #{librarian_token}" }
        active_genre.reload
        expect(response).to have_http_status(:no_content)
        expect(active_genre.is_active).to be_falsey
      end
    end

    context "when a member is authenticated" do
      it "returns a forbidden status" do
        delete api_v1_genre_path(active_genre), headers: { 'Authorization' => "Bearer #{member_token}" }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end