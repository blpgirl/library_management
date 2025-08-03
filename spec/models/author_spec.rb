# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Author, type: :model do
  # Create a valid author record for testing
  let!(:author) { create(:author) }

  # Association tests
  it { is_expected.to have_many(:books).dependent(:restrict_with_exception) }

  # Validation tests
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
  
  # Scope tests
  describe '.active' do
    let!(:active_author) { create(:author, is_active: true) }
    let!(:inactive_author) { create(:author, is_active: false) }

    it 'returns only active authors' do
      expect(Author.active).to include(active_author)
      expect(Author.active).not_to include(inactive_author)
    end  
    
    # test for update
    it 'updates the author name' do
      author.update(name: 'Updated Author Name')
      expect(author.name).to eq('Updated Author Name')
    end

    # test for soft deletion
    it 'soft deletes the author' do
      expect { author.deactivate }.to change { author.reload.is_active }.from(true).to(false)
    end

    # test for restoring a soft deleted author
    it 'restores a soft deleted author' do
      author.deactivate
      expect { author.activate }.to change { author.reload.is_active }.from(false).to(true)
    end
  end
end