# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Borrowing, type: :model do
  # These let blocks are defined once at the top level for basic validations
  # and will not interfere with the more complex tests in nested describe blocks.
  describe 'validations' do
    let(:user) { create(:user) }
    let(:book) { create(:book) }
    subject { build(:borrowing, user: user, book: book) }

    it { is_expected.to belong_to(:book) }
    it { is_expected.to validate_presence_of(:borrowed_at) }
    it { is_expected.to validate_presence_of(:due_date) }
  end
  
  # Custom validations
  describe 'due_date cannot be in the past' do
    let(:user) { create(:user) }
    let(:book) { create(:book) }
    let(:borrowing) { build(:borrowing, user: user, book: book, due_date: 1.day.ago) }

    it 'is not valid if due_date is in the past' do
      expect(borrowing).not_to be_valid
    end
  end

  
  # Custom validation uniqueness user cannot borrow the same book twice without returning it
  describe 'validations for user borrowing a book' do
    # Corrected: Define `user` and `book` within this describe block
    # so they are available to all nested tests.
    let(:borrowing_user) { create(:user) }
    let(:borrowing_book) { create(:book, total_copies: 2) }
    let(:borrowing) { build(:borrowing, user: borrowing_user, book: borrowing_book) }

    it 'is valid if the user has not borrowed the book' do
      expect(borrowing).to be_valid
    end
    
    it 'is not valid if the user has already borrowed the same book' do
      create(:borrowing, user: borrowing_user, book: borrowing_book)
      expect(borrowing).not_to be_valid
    end

    # the test is valid when the previous borrowing has been returned
    it 'is valid if the previous borrowing has been returned' do
      create(:borrowing, user: borrowing_user, book: borrowing_book, returned_at: Time.current)
      # Create a new borrowing instance. This should now be valid.
      new_borrowing = build(:borrowing, user: borrowing_user, book: borrowing_book)
      expect(new_borrowing).to be_valid
    end
    
    it 'is not valid if the user is not active' do
      borrowing_user.update(is_active: false)
      expect(borrowing).not_to be_valid
      expect(borrowing.errors[:user]).to include("is not active")
    end
    
    it 'is not valid if the book is not active' do
      borrowing_book.update(is_active: false)
      expect(borrowing).not_to be_valid
      expect(borrowing.errors[:book]).to include("is not active")
    end
    
    it 'is valid if the user is active and the book is active' do
      borrowing_user.update(is_active: true)
      borrowing_book.update(is_active: true)
      expect(borrowing).to be_valid
    end
    
    it 'is valid if the user borrows a different book' do
      create(:borrowing, user: borrowing_user, book: borrowing_book)
      # Create a fresh book for this specific test
      another_book = create(:book)
      another_borrowing = build(:borrowing, user: borrowing_user, book: another_book)
      expect(another_borrowing).to be_valid
    end
  end

  # Test that the borrowing can be returned
  describe '#returned?' do
    let(:user) { create(:user) }
    let(:book) { create(:book) }
    let(:borrowing) { create(:borrowing, user: user, book: book) }

    it 'returns true if the borrowing has been returned' do
      borrowing.update(returned_at: Time.current)
      expect(borrowing.returned?).to be_truthy
    end

    it 'returns false if the borrowing has not been returned' do
      expect(borrowing.returned?).to be_falsey
    end
  end

end
