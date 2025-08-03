class Book < ApplicationRecord
  # Includes the Activatable concern for soft deletion logic.
  include Activatable
  
  # A book has many borrowings.
  has_many :borrowings, dependent: :destroy
  # A book belongs to a genre.
  belongs_to :genre
  # A book belongs to an author.
  belongs_to :author

  # Validations
  validates :title, presence: true
  validates :author, presence: true
  validates :genre, presence: true
  validates :isbn, presence: true, uniqueness: true
  validates :total_copies, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :available_copies, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: :total_copies }
  
  # Set initial available_copies on creation
  before_validation :set_initial_available_copies, on: :create

  private

  def set_initial_available_copies
    self.available_copies ||= self.total_copies
  end
end
