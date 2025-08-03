class User < ApplicationRecord
  # Includes the Activatable concern for soft deletion logic.
  include Activatable
  
  # Devise modules for JWT authentication.
  # We will handle registrations and sessions manually to align with the API-only approach.
  devise :database_authenticatable, :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  # A user belongs to a role.
  belongs_to :role

  # A user has many borrowings.
  has_many :borrowings, dependent: :destroy

  scope :active, -> { where(is_active: true) }

  # Validations
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :role, presence: true
  validates :is_active, inclusion: { in: [true], message: "User must be active upon creation" }, on: :create

  # Helper methods for role-based authorization
  def librarian?
    role.name == "librarian"
  end

  def member?
    role.name == "member"
  end
end
