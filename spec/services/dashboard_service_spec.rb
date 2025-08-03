# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DashboardService, type: :service do
  let(:librarian_role) { create(:role, name: 'librarian') }
  let(:member_role) { create(:role, name: 'member') }
  let(:librarian) { create(:user, role: librarian_role) }
  let(:member) { create(:user, role: member_role) }

  let!(:active_books) { create_list(:book, 5, is_active: true) }
  let!(:inactive_book) { create(:book, is_active: false) }

  describe '.librarian_data' do
    # Create test data for borrowings
    let!(:active_borrowing) do
      create(:borrowing, user: member, book: active_books.first, borrowed_at: 10.days.ago, due_date: 5.days.from_now)
    end
    let!(:overdue_borrowing_1) do
      create(:borrowing, user: member, book: active_books.second, borrowed_at: 20.days.ago, due_date: 10.days.ago)
    end
    let!(:overdue_borrowing_2) do
      create(:borrowing, user: member, book: active_books.third, borrowed_at: 15.days.ago, due_date: 5.days.ago)
    end
    let!(:due_today_borrowing) do
      create(:borrowing, user: member, book: active_books.fourth, borrowed_at: 10.days.ago, due_date: Date.today)
    end
    let!(:returned_borrowing) do
      create(:borrowing, user: member, book: active_books.fifth, returned_at: Date.yesterday)
    end
    let!(:canceled_borrowing) do
      create(:borrowing, user: member, book: active_books.fifth, is_canceled: true)
    end

    it 'returns the correct total number of active books' do
      data = described_class.librarian_data
      expect(data[:total_books]).to eq(active_books.count)
    end

    it 'returns the correct total number of borrowed books (active borrowings)' do
      data = described_class.librarian_data
      # The count should include active_borrowing, overdue_borrowing_1, overdue_borrowing_2, and due_today_borrowing
      expect(data[:total_borrowed_books]).to eq(4)
    end

    it 'returns the correct number of books due today' do
      data = described_class.librarian_data
      expect(data[:books_due_today]).to eq(1)
    end

    it 'returns a list of overdue borrowings with the correct format' do
      data = described_class.librarian_data
      expect(data[:overdue_borrowings].count).to eq(2)
      
      # Test the format of the first overdue borrowing
      expect(data[:overdue_borrowings].first[:user_name]).to eq(overdue_borrowing_1.user.name)
      expect(data[:overdue_borrowings].first[:book_title]).to eq(overdue_borrowing_1.book.title)
      expect(data[:overdue_borrowings].first[:due_date]).to eq(overdue_borrowing_1.due_date.strftime("%b %d, %Y"))

      # Test the format of the second overdue borrowing
      expect(data[:overdue_borrowings].second[:user_name]).to eq(overdue_borrowing_2.user.name)
      expect(data[:overdue_borrowings].second[:book_title]).to eq(overdue_borrowing_2.book.title)
      expect(data[:overdue_borrowings].second[:due_date]).to eq(overdue_borrowing_2.due_date.strftime("%b %d, %Y"))
    end
  end

  describe '.member_data' do
    let(:member_with_books) { create(:user, role: member_role) }
    let(:other_member) { create(:user, role: member_role) }
    let!(:borrowed_book_1) { create(:book, title: 'Book 1') }
    let!(:borrowed_book_2) { create(:book, title: 'Book 2') }
    let!(:overdue_book) { create(:book, title: 'Overdue Book') }

    # Create borrowings for the test member
    let!(:active_borrowing_1) do
      create(:borrowing, user: member_with_books, book: borrowed_book_1, due_date: Date.today + 1.week)
    end
    let!(:active_borrowing_2) do
      create(:borrowing, user: member_with_books, book: borrowed_book_2, due_date: Date.today + 2.days)
    end
    let!(:overdue_borrowing) do
      create(:borrowing, user: member_with_books, book: overdue_book, due_date: Date.today - 1.day)
    end

    # Create a borrowing for another member to ensure it is not included
    let!(:other_members_borrowing) { create(:borrowing, user: other_member, book: active_books.first) }

    it 'returns the correct list of borrowed books for the user' do
      data = described_class.member_data(member_with_books)
      expect(data[:borrowed_books].count).to eq(3)

      titles = data[:borrowed_books].map { |b| b[:title] }
      expect(titles).to include('Book 1', 'Book 2', 'Overdue Book')
    end

    it 'returns the correct list of overdue books for the user' do
      data = described_class.member_data(member_with_books)
      expect(data[:overdue_books].count).to eq(1)
      expect(data[:overdue_books].first[:title]).to eq('Overdue Book')
    end

    it 'returns the correct format for borrowed and overdue books' do
      data = described_class.member_data(member_with_books)

      # Test the format of a borrowed book
      borrowed = data[:borrowed_books].find { |b| b[:title] == 'Book 1' }
      expect(borrowed[:title]).to eq(active_borrowing_1.book.title)
      expect(borrowed[:author]).to eq(active_borrowing_1.book.author.name)
      expect(borrowed[:due_date]).to eq(active_borrowing_1.due_date.strftime("%b %d, %Y"))
      
      # Test the format of an overdue book
      overdue = data[:overdue_books].first
      expect(overdue[:title]).to eq(overdue_borrowing.book.title)
      expect(overdue[:author]).to eq(overdue_borrowing.book.author.name)
      expect(overdue[:due_date]).to eq(overdue_borrowing.due_date.strftime("%b %d, %Y"))
    end
  end
end
