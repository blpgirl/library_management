# frozen_string_literal: true
require 'rails_helper'
RSpec.describe Role, type: :model do
  # Create a valid role record for the uniqueness tests
  let!(:role) { create(:role) }

  # Association tests
  it { is_expected.to have_many(:users).dependent(:restrict_with_exception) }

  # Validation tests
  it { is_expected.to validate_presence_of(:name) }
  # Use case_insensitive matcher to match database collation
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
  
  # Scope tests
  describe '.active' do
    let!(:active_role) { create(:role, is_active: true) }
    let!(:inactive_role) { create(:role, is_active: false) }    
    it 'returns only active roles' do
      expect(described_class.active).to include(active_role)
      expect(described_class.active).not_to include(inactive_role)
    end
  end         

  # change below to restrict_with_exception if you want to raise an exception instead of an error
  # dependent: :restrict_with_error will add an error to the role if it has associated users
  # dependent: :restrict_with_exception will raise an exception if it has associated users
  describe 'soft deletion' do
    let(:role_to_deactivate) { create(:role) }   
    it 'deactivates the role instead of deleting it' do
      expect { role_to_deactivate.deactivate }.to change { role_to_deactivate.is_active }.from(true).to(false)
      expect(role_to_deactivate.reload.is_active).to be_falsey
    end
  end 

  # Test that the role cannot be destroyed if it has associated users
  # This will raise an exception if you try to delete a role that has associated users
  # We will only allow deactivation of roles
  # This is to ensure that roles are not deleted if they are associated with users                                                                           
  describe 'dependent: :restrict_with_exception' do
    let(:role_to_destroy) { create(:role) }
    let!(:user) { create(:user, role: role_to_destroy) }

    it 'raises ActiveRecord::DeleteRestrictionError when trying to destroy a role with associated users' do
      expect { role_to_destroy.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError)
    end
  end
end
