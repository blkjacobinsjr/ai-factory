class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_one :profile, dependent: :destroy
  has_many :goals, dependent: :destroy
  # Lets LearningSessionsController scope by Current.user.learning_sessions
  # (through the goals association) the same way Goal itself is scoped.
  has_many :learning_sessions, through: :goals

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  # The DB has a unique index (belt), but without this validation a
  # duplicate signup hits that index directly and raises
  # ActiveRecord::RecordNotUnique — a 500 instead of a normal form error
  # (suspenders). normalizes above already downcases, so this is
  # effectively case-insensitive.
  validates :email_address, presence: true, uniqueness: true

  # has_secure_password only enforces bcrypt's 72-char UPPER limit — without
  # a lower bound, a 3-char password is accepted as-is (review finding F4).
  # allow_nil: has_secure_password already requires presence on create, and
  # a nil check here avoids double-erroring an already-blank password.
  validates :password, length: { minimum: 8 }, allow_nil: true
end
