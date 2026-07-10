# A saved link: a human-readable title plus the URL it points to.
# This model is the single gatekeeper for bookmark data — controllers
# and console alike must pass these rules, so invalid rows can't reach
# the database.
class Bookmark < ApplicationRecord
  # Without a title the homepage list would show a blank, unclickable row.
  validates :title, presence: true
end
