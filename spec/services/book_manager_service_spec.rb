# frozen_string_literal: true
require 'rails_helper'

RSpec.describe BookManagerService, type: :service do
  let(:active_user) { create(:user, is_active: true) }
  let(:inactive_user) { create(:user, is_active: false) }
  let(:available_book) { create(:book, total_copies: 5, available_copies: 5, is_active: true) }
  let(:unavailable_book) { create(:book, total_copies: 5, available_copies: 0, is_active: true) }
  let(:inactive_book) { create(:book, total_copies: 5, available_copies: 5, is_active: false) }

  describe '.borrow_book' do
    context 'when all conditions are met' do
      it 'creates a new borrowing record and returns a success result' do
        result = described_class.borrow_book(active_user, available_book)
        expect(result[:success]).to be true
        expect(result[:borrowing]).to be_a(Borrowing)
        expect(Borrowing.count).to eq(1)
      end

      it 'returns a failed result if the user already has an unreturned copy' do
        create(:borrowing, user: active_user, book: available_book)
        result = described_class.borrow_book(active_user, available_book)
        expect(result[:success]).to be false
        expect(result[:message]).to eq('You have already borrowed this book.')
      end
    end

    context 'when the book is not available' do
      it 'does not create a borrowing record and returns a failure result' do
        result = described_class.borrow_book(active_user, unavailable_book)
        expect(result[:success]).to be false
        expect(result[:message]).to eq('Book is not available.')
        expect(Borrowing.count).to eq(0)
      end
    end

    context 'when the book is inactive' do
      it 'does not create a borrowing record and returns a failure result' do
        result = described_class.borrow_book(active_user, inactive_book)
        expect(result[:success]).to be false
        expect(result[:message]).to eq('The book is not active.')
        expect(Borrowing.count).to eq(0)
      end
    end

    context 'when the user is inactive' do
      it 'does not create a borrowing record and returns a failure result' do
        result = described_class.borrow_book(inactive_user, available_book)
        expect(result[:success]).to be false
        expect(result[:message]).to eq('The user is not active.')
        expect(Borrowing.count).to eq(0)
      end
    end
  end

  describe '.return_book' do
    let(:borrowing) { create(:borrowing, user: active_user, book: available_book) }

    context 'when the borrowing is active' do
      it 'updates the borrowing record and returns a success result' do
        result = described_class.return_book(borrowing)
        expect(result[:success]).to be true
        expect(borrowing.reload.returned_at).to_not be_nil
      end
    end

    context 'when the borrowing has already been returned' do
      before { borrowing.update(returned_at: 1.day.ago) }

      it 'does not update the record and returns a failure result' do
        result = described_class.return_book(borrowing)
        expect(result[:success]).to be false
        expect(result[:message]).to eq('Book has already been returned.')
      end
    end
  end
end
