# Request tests for bookmark CRUD: they drive the app the way a browser
# would (real routes, real controller, real views). If these break, users
# can't reach or manage their bookmarks even if the model is fine.
require "test_helper"

class BookmarksControllerTest < ActionDispatch::IntegrationTest
  test "GET / links the tailwind stylesheet" do
    # Guards the styling foundation: if Tailwind's compiled CSS ever stops
    # being linked (gem removed, layout edited), every page silently
    # degrades to unstyled HTML — this catches that as a red test.
    get root_url

    assert_select "link[rel=stylesheet][href*=?]", "tailwind"
  end

  test "bookmark pages wrap content in a centered container" do
    # The layout, not each view, owns page width/centering. All three
    # bookmark pages must sit inside <main class="container"> — if a view
    # escapes the wrapper, its content stretches edge-to-edge unstyled.
    [root_url, new_bookmark_url, edit_bookmark_url(bookmarks(:rails_guides))].each do |url|
      get url
      assert_select "main.container", 1
    end
  end

  test "index renders each bookmark as a card with actions" do
    # Pins the index's component structure: one .card per bookmark, and the
    # card must contain everything a user needs — the link itself plus both
    # actions. If Edit or Delete falls out of the card, users lose that action.
    get root_url

    assert_select ".card", Bookmark.count do
      assert_select "a[href=?]", bookmarks(:rails_guides).url
      assert_select "a", text: "Edit"
      assert_select "button[type=submit]", text: "Delete"
    end
  end

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

  test "DELETE /bookmarks/:id removes the bookmark" do
    bookmark = bookmarks(:rails_guides)

    assert_difference("Bookmark.count", -1) do
      delete bookmark_url(bookmark)
    end
    assert_redirected_to root_url

    # Gone from the database AND from what the user sees on the homepage.
    get root_url
    assert_no_match bookmark.title, response.body
  end
end
