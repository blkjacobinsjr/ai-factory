# Request tests for bookmark CRUD: they drive the app the way a browser
# would (real routes, real controller, real views). If these break, users
# can't reach or manage their bookmarks even if the model is fine.
require "test_helper"

class BookmarksControllerTest < ActionDispatch::IntegrationTest
  test "GET / renders the bookmarks index" do
    # The bookmarks list IS the homepage — the app's front door.
    get root_url

    assert_response :success
  end

  test "POST /bookmarks persists a bookmark that appears on the index" do
    # The whole write path in one pass: form submit → validation → save →
    # redirect → the new link is actually visible on the homepage.
    assert_difference("Bookmark.count", 1) do
      post bookmarks_url, params: { bookmark: { title: "Example", url: "https://example.com" } }
    end
    assert_redirected_to root_url

    get root_url
    assert_match "Example", response.body
  end

  test "PATCH /bookmarks/:id updates the title" do
    # Uses the fixture bookmark; only the title changes, the url must survive.
    bookmark = bookmarks(:rails_guides)

    patch bookmark_url(bookmark), params: { bookmark: { title: "Ruby on Rails Guides" } }

    assert_redirected_to root_url
    assert_equal "Ruby on Rails Guides", bookmark.reload.title
  end
end
