# Request tests for bookmark CRUD: they drive the app the way a browser
# would (real routes, real controller, real views). If these break, users
# can't reach or manage their bookmarks even if the model is fine.
require "test_helper"

class BookmarksControllerTest < ActionDispatch::IntegrationTest
  # Every controller now requires a session by default (Rails 8's
  # Authentication concern, included in ApplicationController). All tests
  # below except the anonymous one need a signed-in user to reach bookmarks
  # at all — sign_in_as comes from the generator's own test helper.
  setup { sign_in_as users(:one) }

  test "anonymous visitor is redirected to sign-in" do
    sign_out
    # The homepage is bookmark data — it must require a session, not just
    # look private. Every other test in this file signs in first (see setup);
    # this is the one that proves what happens WITHOUT signing in.
    get root_url

    assert_redirected_to new_session_path
  end

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

  test "new form uses styled input, label and button components" do
    # Pins the form's component classes. Both fields share .input and both
    # labels .label, so new and edit (same partial) can't drift apart, and
    # a class rename in the CSS without a view update fails here.
    get new_bookmark_url

    assert_select "input.input#bookmark_title"
    assert_select "input.input#bookmark_url"
    assert_select "label.label", 2
    assert_select "input.btn[type=submit]"
  end

  test "validation errors render inside form-errors" do
    # The error box is the user's only explanation of a rejected submit;
    # this pins that messages land in the styled .form-errors component
    # rather than an unstyled list that's easy to miss.
    post bookmarks_url, params: { bookmark: { title: "", url: "https://example.com" } }

    assert_response :unprocessable_entity
    assert_select ".form-errors li", text: /Title/
  end

  test "homepage shows the 5-step pipeline strip above the list" do
    # Pins the showcase strip: exactly the 5 factory phases, in order,
    # rendered before the bookmark cards so it reads as a header, not a footer.
    get root_url

    assert_select ".pipeline .step", 5
    # Labels must appear in pipeline ORDER, not merely exist somewhere.
    assert_equal %w[refine plan implement review merge],
                 css_select(".pipeline .step-label").map(&:text)
    # Anchor on the strip's class attribute: a bare "pipeline" search would
    # match "controllers/pipeline_controller" in the <head> importmap and
    # pass even with the strip below the list (review F1, ticket 003).
    assert_operator response.body.index('class="pipeline"'), :<, response.body.index("Bookmarks"),
                    "pipeline strip must come before the bookmarks list"
  end

  test "pipeline strip shows the current factory phase" do
    # The badge must reflect .factory/state at render time — comparing
    # against FactoryState.phase (not a literal) keeps this test valid
    # whatever phase the factory is in while the suite runs.
    get root_url

    assert_select ".pipeline .phase-badge", text: FactoryState.phase
  end

  test "pipeline strip is wired to the Stimulus controller" do
    # The animation is pure client-side; what the server CAN guarantee is
    # the contract the JS depends on: controller attachment, one target
    # per step, a detail line per step, and a replay control. If any of
    # these drop out, the strip silently stops animating.
    get root_url

    assert_select ".pipeline[data-controller=pipeline]"
    assert_select ".pipeline [data-pipeline-target=step]", 5
    assert_select ".pipeline .step[data-detail]", 5
    assert_select ".pipeline button[data-action*=pipeline]"
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
