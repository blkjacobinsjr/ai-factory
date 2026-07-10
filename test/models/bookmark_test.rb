# Tests for the Bookmark model's validation rules.
# These guard the data layer: if they break, bad records (no title,
# garbage URLs) could silently enter the database.
require "test_helper"

class BookmarkTest < ActiveSupport::TestCase
  test "is invalid with a blank title" do
    # A bookmark without a title would render as an unnamed blank row
    # on the homepage — we reject it at the model so no code path can save one.
    bookmark = Bookmark.new(title: "", url: "https://example.com")

    assert_not bookmark.valid?
    assert bookmark.errors[:title].any?, "expected an error on :title"
  end
end
