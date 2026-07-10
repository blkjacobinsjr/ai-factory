# A learning objective a user is tracking. The first model in this app
# that's genuinely private per user — every lookup goes through
# Current.user.goals, never Goal.find directly, so a user can never load
# a row that isn't theirs.
class Goal < ApplicationRecord
  belongs_to :user
  has_many :learning_sessions, dependent: :destroy
  has_many :resources, dependent: :destroy

  # Integer-backed, not string: Ruby symbols can't hold the brief's literal
  # "in-progress" (hyphens aren't legal in identifiers), and a string column
  # would need its own validation since Rails enums don't enforce values at
  # the DB layer either way. The hyphen is a display concern (see the view),
  # not a storage one. Filtering uses this same key: ?status=in_progress.
  enum :status, { planned: 0, in_progress: 1, done: 2 }

  validates :title, presence: true
end
