require 'rails_helper'

RSpec.describe "Users::Registrations", type: :request do
  let!(:member_role) { create(:member_role) }
  let(:valid_params) do
    {
      user: {
        name: 'New User',
        email: 'newuser@example.com',
        password: 'password',
        password_confirmation: 'password'
      }
    }
  end

  describe "POST /signup" do
    context "with valid parameters" do
      it "creates a new user and assigns the 'member' role" do
        expect do
          post '/signup', params: valid_params
        end.to change(User, :count).by(1)
        expect(response).to have_http_status(:ok)
        expect(json_response['status']['message']).to eq('Signed up successfully.')
        expect(User.last.role.name).to eq('member')
      end
    end
    
    context "with invalid parameters" do
      it "does not create a new user and returns errors" do
        invalid_params = { user: { name: '', email: 'invalid-email', password: '123', password_confirmation: '1234' } }
        expect do
          post '/signup', params: invalid_params
        end.to_not change(User, :count)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['status']['message']).to include("Email is invalid", "Name can't be blank", "Password confirmation doesn't match Password")
      end
    end
  end
end