# A saved link: a human-readable title plus the URL it points to.
# This model is the single gatekeeper for bookmark data — controllers
# and console alike must pass these rules, so invalid rows can't reach
# the database.
class Bookmark < ApplicationRecord
  # Without a title the homepage list would show a blank, unclickable row.
  validates :title, presence: true

  # Only allow real web addresses: must start with http:// or https://
  # and have something after the slashes. This blocks dead links like
  # "not-a-url" and dangerous schemes like "javascript:..." which could
  # execute code when clicked. Tradeoff: we check the *shape* only —
  # whether the site actually exists is out of scope (see ticket).
  validates :url, presence: true, format: { with: %r{\Ahttps?://.+\z},
                                            message: "must start with http:// or https://" }
end
