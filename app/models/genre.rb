class Genre < ApplicationRecord    
  # Includes the Activatable concern for soft deletion logic.
  include Activatable

  # A genre has many books.
  has_many :books, dependent: :restrict_with_exception

  # Validations
  validates :name, presence: true, uniqueness: true

  # Scopes
  scope :active, -> { where(is_active: true) }
end
