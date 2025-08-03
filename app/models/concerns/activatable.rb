# This concern encapsulates the logic for soft-deleting records.
# It provides an `active` scope and `deactivate`/`activate` instance methods.
module Activatable
  extend ActiveSupport::Concern

  included do
    scope :active, -> { where(is_active: true) }
  end

  def deactivate
    update(is_active: false)
  end

  def activate
    update(is_active: true)
  end
end