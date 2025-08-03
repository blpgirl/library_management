# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Genre, type: :model do
  # Create a valid genre record for the uniqueness tests
  let!(:genre) { create(:genre) }

  # Association tests
  it { is_expected.to have_many(:books).dependent(:restrict_with_exception) }

  # Validation tests
  it { is_expected.to validate_presence_of(:name) }
  # Use case_insensitive matcher to match database collation
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }

  # Scope tests
  describe '.active' do
    let!(:active_genre) { create(:active_genre) }
    let!(:inactive_genre) { create(:inactive_genre) }

    it 'returns only active genres' do
      expect(described_class.active).to include(active_genre)
      expect(described_class.active).not_to include(inactive_genre)
    end
  end

  # Soft deletion tests
  describe 'soft deletion' do     
    let(:genre_to_deactivate) { create(:genre) }

    it 'deactivates the genre instead of deleting it' do
      expect { genre_to_deactivate.deactivate }.to change { genre_to_deactivate.is_active }.from(true).to(false)
      expect(genre_to_deactivate.reload.is_active).to be_falsey
    end
  end
end
