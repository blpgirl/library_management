require 'rails_helper'

RSpec.describe "Api::V1::Dashboards", type: :request do
  let!(:librarian_role) { create(:librarian_role) }
  let!(:member_role) { create(:member_role) }
  let!(:librarian) { create(:librarian, role: librarian_role) }
  let!(:member) { create(:member, role: member_role) }
  
  # Devise JWT authentication tokens
  let(:librarian_token) { Warden::JWTAuth::UserEncoder.new.call(librarian, :user, nil).first }
  let(:member_token) { Warden::JWTAuth::UserEncoder.new.call(member, :user, nil).first }

  describe "GET /api/v1/dashboards/librarian" do
    context "when a librarian is authenticated" do
      it "returns the librarian dashboard data" do
        get "/api/v1/dashboards/librarian", headers: { 'Authorization' => "Bearer #{librarian_token}" }
        expect(response).to have_http_status(:ok)
        expect(json_response).to include("total_books", "total_borrowed_books", "books_due_today", "overdue_borrowings")
      end
    end

    context "when a member is authenticated" do
      it "returns a forbidden status" do
        get "/api/v1/dashboards/librarian", headers: { 'Authorization' => "Bearer #{member_token}" }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "GET /api/v1/dashboards/member" do
    context "when a member is authenticated" do
      it "returns the member dashboard data" do
        get "/api/v1/dashboards/member", headers: { 'Authorization' => "Bearer #{member_token}" }
        expect(response).to have_http_status(:ok)
        expect(json_response).to include("borrowed_books", "overdue_books")
      end
    end

    context "when a librarian is authenticated" do
      it "returns a forbidden status" do
        get "/api/v1/dashboards/member", headers: { 'Authorization' => "Bearer #{librarian_token}" }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end