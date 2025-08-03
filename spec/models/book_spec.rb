# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Book, type: :model do
  # Create a valid book record for the uniqueness tests
  let!(:book) { create(:book) }

  # Association tests
  it { is_expected.to have_many(:borrowings).dependent(:destroy) }
  it { is_expected.to belong_to(:author) }
  it { is_expected.to belong_to(:genre) }

  # Validation tests
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:isbn) }

  # Use case_insensitive matcher to match database collation
  it { is_expected.to validate_uniqueness_of(:isbn).case_insensitive }

  # Numericality tests
  it { is_expected.to validate_numericality_of(:total_copies).is_greater_than_or_equal_to(0) }
  it { is_expected.to validate_numericality_of(:available_copies).is_greater_than_or_equal_to(0) }

  # Test for available_copies not exceeding total_copies
  it 'is invalid if available_copies exceeds total_copies' do
    book.total_copies = 5
    book.available_copies = 6
    expect(book).not_to be_valid
    expect(book.errors[:available_copies]).to include("must be less than or equal to #{book.total_copies}")
  end

  # Scope tests
  describe '.active' do
    let!(:active_book) { create(:book, is_active: true) }
    let!(:inactive_book) { create(:book, is_active: false) }

    it 'returns only active books' do
      expect(Book.active).to include(active_book)
      expect(Book.active).not_to include(inactive_book)
    end
  end
end
