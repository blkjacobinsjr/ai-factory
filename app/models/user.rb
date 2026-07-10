class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_one :profile, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  # The DB has a unique index (belt), but without this validation a
  # duplicate signup hits that index directly and raises
  # ActiveRecord::RecordNotUnique — a 500 instead of a normal form error
  # (suspenders). normalizes above already downcases, so this is
  # effectively case-insensitive.
  validates :email_address, presence: true, uniqueness: true
end
