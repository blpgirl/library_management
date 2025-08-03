class Role < ApplicationRecord
  # Includes the Activatable concern for soft deletion logic.
  include Activatable

  # Restrict deletion of roles if they are associated with users
  # This will raise an exception if you try to delete a role that has associated users
  # We will only allow deactivation of roles
  has_many :users, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: true

  scope :active, -> { where(is_active: true) }

end
