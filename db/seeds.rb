# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Clear existing data to prevent duplicates
Borrowing.destroy_all
User.destroy_all
Book.destroy_all
Genre.destroy_all
Author.destroy_all
Role.destroy_all

puts "Creating roles..."
librarian_role = Role.create!(name: 'librarian')
member_role = Role.create!(name: 'member')

puts "Creating genres..."
fantasy_genre = Genre.create!(name: 'Fantasy')
classic_fiction_genre = Genre.create!(name: 'Classic Fiction')
dystopian_fiction_genre = Genre.create!(name: 'Dystopian Fiction')
romance_genre = Genre.create!(name: 'Romance')
science_fiction_genre = Genre.create!(name: 'Science Fiction')
mystery_genre = Genre.create!(name: 'Mystery')

puts "Creating authors..."
tolkien_author = Author.create!(name: "J.R.R. Tolkien")
lee_author = Author.create!(name: "Harper Lee")
orwell_author = Author.create!(name: "George Orwell")
austen_author = Author.create!(name: "Jane Austen")
adams_author = Author.create!(name: "Douglas Adams")

puts "Creating users..."
# Create a Librarian and three Member users
librarian = User.create!(
  name: 'Librarian Admin',
  email: 'librarian@example.com',
  password: 'password',
  role: librarian_role
)

member1 = User.create!(
  name: 'Library Member',
  email: 'member@example.com',
  password: 'password',
  role: member_role,
  is_active: true
)

member2 = User.create!(
  name: 'John Doe',
  email: 'john.doe@example.com',
  password: 'password',
  role: member_role,
  is_active: true
)

puts "Creating books..."
# Create 5 popular books by Goodreads, with random copies
popular_books = [
  { title: "The Lord of the Rings", author: tolkien_author, genre: fantasy_genre, isbn: "9780547928230", total_copies: rand(10..20) },
  { title: "To Kill a Mockingbird", author: lee_author, genre: classic_fiction_genre, isbn: "9780061120084", total_copies: rand(10..20) },
  { title: "1984", author: orwell_author, genre: dystopian_fiction_genre, isbn: "9780451524935", total_copies: rand(10..20) },
  { title: "Pride and Prejudice", author: austen_author, genre: romance_genre, isbn: "9780141439518", total_copies: rand(10..20) },
  { title: "The Hitchhiker's Guide to the Galaxy", author: adams_author, genre: science_fiction_genre, isbn: "9780345391803", total_copies: rand(10..20) }
]

books = popular_books.map do |book_data|
  Book.create!(book_data)
end

# Create an inactive book for testing purposes
inactive_book = Book.create!(
  title: 'The Hobbit',
  author: tolkien_author,
  genre: fantasy_genre,
  isbn: '9780345339683',
  total_copies: 1,
  available_copies: 1,
  is_active: false
)

# Create 5 other books with some available copies
5.times do |i|
  Book.create!(
    title: Faker::Book.title,
    author: Author.create!(name: Faker::Book.author),
    genre: mystery_genre,
    isbn: Faker::Code.isbn,
    total_copies: 5,
    available_copies: i.even? ? 5 : rand(0..4)
  )
end

puts "Creating borrowings..."
# Create some borrowings for the members
Borrowing.create!(user: member1, book: books[0], borrowed_at: 1.week.ago, due_date: 1.week.from_now) # Active borrowing
borrow = Borrowing.create!(user: member1, book: books[1], borrowed_at: 3.weeks.ago, due_date: Time.current)
borrow.update(due_date: 1.week.ago) # Update due date to make it overdue
Borrowing.create!(user: member2, book: books[2], borrowed_at: 5.days.ago, due_date: 7.days.from_now) # Active 
Borrowing.create!(user: member2, book: books[3], borrowed_at: 2.weeks.ago, due_date: Time.current)
Borrowing.create!(user: member2, book: books[4], borrowed_at: 2.days.ago, due_date: 13.days.from_now)
puts "Seeding completed successfully!"
# Add a canceled borrowing for testing purposes
canceled_borrowing = Borrowing.create!(user: member1, book: books.last, borrowed_at: 1.day.ago, due_date: 14.days.from_now, is_canceled: true)
puts "Created #{Borrowing.count} borrowings, #{User.count} users, #{Book.count} books, #{Genre.count} genres, #{Author.count} authors, and #{Role.count} roles."