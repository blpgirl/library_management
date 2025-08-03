class Author < ApplicationRecord
  # Includes the Activatable concern for soft deletion logic.
  include Activatable

  # An author can have multiple books.
  # We will restrict deletion of authors if they are associated with books.
  # This will raise an exception if you try to delete an author that has associated books.
  # We will only allow deactivation of authors.
  has_many :books, dependent: :restrict_with_exception

  # Validations
  validates :name, presence: true, uniqueness: true

  # Scopes
  scope :active, -> { where(is_active: true) }
end
