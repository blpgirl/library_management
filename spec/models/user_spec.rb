require 'rails_helper'

RSpec.describe User, type: :model do
  let!(:member_role) { create(:member_role) }
  let!(:librarian_role) { create(:librarian_role) }

  it { is_expected.to have_many(:borrowings).dependent(:destroy) }
  it { is_expected.to belong_to(:role) }
  it {
    user = build(:user, name: "Test Name", email: "unique@example.com", role: member_role, encrypted_password: "password123")
    expect(user).to validate_uniqueness_of(:email).case_insensitive
  }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:role) }

  # Test database columns
  it { is_expected.to have_db_column(:email).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:encrypted_password).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_index(:email).unique(true) }

  describe 'CRUD Operations' do
    it 'creates a valid user' do
      user = build(:user, role: member_role)
      expect(user).to be_valid
    end
    
    it 'updates a user' do
      user = create(:user, role: member_role)
      user.update(name: 'New Name')
      expect(user.reload.name).to eq('New Name')
    end
    
    it 'deactivates a user' do
      user = create(:user, role: member_role)
      user.deactivate
      expect(user.reload.is_active).to be_falsey
    end
    
    it 'prevents creation of a user with a duplicate email' do
      create(:user, email: 'test@example.com', role: member_role)
      duplicate_user = build(:user, email: 'test@example.com', role: member_role)
      expect(duplicate_user).not_to be_valid
    end
  end
  
  describe '#librarian?' do
    it 'returns true if the user has a librarian role' do
      user = create(:user, role: librarian_role)
      expect(user.librarian?).to be(true)
    end
    
    it 'returns false if the user does not have a librarian role' do
      user = create(:user, role: member_role)
      expect(user.librarian?).to be(false)
    end
  end

  describe '#member?' do
    it 'returns true if the user has a member role' do
      user = create(:user, role: member_role)
      expect(user.member?).to be(true)
    end
    
    it 'returns false if the user does not have a member role' do
      user = create(:user, role: librarian_role)
      expect(user.member?).to be(false)
    end
  end
end
