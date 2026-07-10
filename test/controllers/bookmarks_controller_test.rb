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
end
