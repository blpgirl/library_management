# frozen_string_literal: true
require 'rails_helper'

RSpec.describe BorrowingService, type: :service do
  let(:service) { described_class.new }
  let(:active_user) { create(:user, is_active: true) }
  let(:inactive_user) { create(:user, is_active: false) }
  let(:available_book) { create(:book, total_copies: 5, available_copies: 5, is_active: true) }
  let(:unavailable_book) { create(:book, total_copies: 5, available_copies: 0, is_active: true) }
  let(:inactive_book) { create(:book, total_copies: 5, available_copies: 5, is_active: false) }
  
  describe '#borrow_book' do
    context 'when all conditions are met' do
      it 'creates a borrowing record and decrements available copies in a transaction' do
        expect { service.borrow_book(user: active_user, book: available_book) }.to change(
          Borrowing, :count
        ).by(1).and change { available_book.reload.available_copies }.by(-1)
      end

      it 'returns a borrowing object on success' do
        result = service.borrow_book(user: active_user, book: available_book)
        expect(result).to be_a(Borrowing)
      end
    end

    context 'when a condition is not met' do
      it 'returns false and does not change the database state when user is inactive' do
        expect { service.borrow_book(user: inactive_user, book: available_book) }.not_to change(
          Borrowing, :count
        ).and not_change { available_book.reload.available_copies }
        expect(service.borrow_book(user: inactive_user, book: available_book)).to be false
      end

      it 'returns false and does not change the database state when book is inactive' do
        expect { service.borrow_book(user: active_user, book: inactive_book) }.not_to change(
          Borrowing, :count
        ).and not_change { inactive_book.reload.available_copies }
        expect(service.borrow_book(user: active_user, book: inactive_book)).to be false
      end
      
      it 'returns false when the book has no available copies' do
        expect { service.borrow_book(user: active_user, book: unavailable_book) }.not_to change(
          Borrowing, :count
        ).and not_change { unavailable_book.reload.available_copies }
        expect(service.borrow_book(user: active_user, book: unavailable_book)).to be false
      end
      
      it 'returns false when the user already has an unreturned copy of the book' do
        create(:borrowing, user: active_user, book: available_book)
        expect { service.borrow_book(user: active_user, book: available_book) }.not_to change(
          Borrowing, :count
        ).and not_change { available_book.reload.available_copies }
        expect(service.borrow_book(user: active_user, book: available_book)).to be false
      end
    end
  end

  describe '#return_book' do
    let!(:borrowing) { create(:borrowing, user: active_user, book: available_book) }
    
    before { available_book.decrement!(:available_copies) }

    context 'when the borrowing is unreturned and not canceled' do
      it 'updates the borrowing record and increments available copies in a transaction' do
        expect { service.return_book(borrowing: borrowing) }.to change { borrowing.reload.returned_at }.from(nil).to(
          be_within(1.second).of(Time.current)
        ).and change { available_book.reload.available_copies }.by(1)
        expect(service.return_book(borrowing: borrowing)).to be true
      end
    end

    context 'when the borrowing has already been returned' do
      before { borrowing.update(returned_at: 1.day.ago) }

      it 'returns false and does not change the database state' do
        expect { service.return_book(borrowing: borrowing) }.not_to change { borrowing.reload.returned_at }.and not_change { available_book.reload.available_copies }
        expect(service.return_book(borrowing: borrowing)).to be false
      end
    end
  end

  describe '#cancel_borrowing' do
    let!(:borrowing) { create(:borrowing, user: active_user, book: available_book) }

    before { available_book.decrement!(:available_copies) }

    context 'when the borrowing is unreturned and not canceled' do
      it 'updates the borrowing record and increments available copies in a transaction' do
        expect { service.cancel_borrowing(borrowing: borrowing) }.to change { borrowing.reload.is_canceled }.from(false).to(true).and change { available_book.reload.available_copies }.by(1)
        expect(service.cancel_borrowing(borrowing: borrowing)).to be true
      end
    end

    context 'when the borrowing has already been canceled' do
      before { borrowing.update(is_canceled: true) }

      it 'returns false and does not change the database state' do
        expect { service.cancel_borrowing(borrowing: borrowing) }.not_to change { borrowing.reload.is_canceled }.and not_change { available_book.reload.available_copies }
        expect(service.cancel_borrowing(borrowing: borrowing)).to be false
      end
    end
  end
end
