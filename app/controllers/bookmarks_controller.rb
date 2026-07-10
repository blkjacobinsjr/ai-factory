# Handles every browser request about bookmarks. Each public method below
# answers one URL (see config/routes.rb). Kept deliberately thin: it fetches
# or saves records and picks what to show next — all data rules live in the
# Bookmark model, so nothing here can bypass them.
class BookmarksController < ApplicationController
  # GET / — the homepage: list every saved bookmark, newest first so a
  # just-added bookmark is visible at the top without scrolling.
  def index
    @bookmarks = Bookmark.order(created_at: :desc)
  end
end
