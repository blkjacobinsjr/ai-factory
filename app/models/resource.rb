# A piece of reference material (article/video/repo/doc) attached to a
# Goal — evolved from the old standalone, globally-shared Bookmark.
# Validations are unchanged from Bookmark; only the ownership (belongs_to
# :goal, which belongs_to :user) and resource_type are new.
class Resource < ApplicationRecord
  belongs_to :goal

  # Named resource_type, not "type" — see the migration comment: a column
  # literally named "type" triggers ActiveRecord's Single Table Inheritance.
  enum :resource_type, { article: 0, video: 1, repo: 2, doc: 3 }

  validates :title, presence: true
  validates :url, presence: true, format: { with: %r{\Ahttps?://.+\z},
                                            message: "must start with http:// or https://" }
end
