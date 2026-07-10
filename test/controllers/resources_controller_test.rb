# Resources are attached to a Goal, scoped the same way LearningSessions
# are — through Current.user.goals / Current.user.resources.
require "test_helper"

class ResourcesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "attaches a resource that appears on the goal's page, badged by type" do
    goal = users(:one).goals.create!(title: "Learn Rails", status: "planned")

    assert_difference("Resource.count", 1) do
      post goal_resources_path(goal), params: {
        resource: { title: "Rails Guides", url: "https://guides.rubyonrails.org", resource_type: "doc" }
      }
    end
    assert_redirected_to goal_path(goal)

    get goal_path(goal)
    assert_match "Rails Guides", response.body
    # Asserting the badge ELEMENT, not just the word "doc" anywhere on the
    # page — the attach form's own <select> always contains that word as
    # an option, so a plain text match would pass even with no badge
    # rendered at all (review finding F1, ticket 006 round 1).
    assert_select ".phase-badge", text: "doc"
  end

  test "rejects a resource with a blank title or a non-http(s) url" do
    goal = users(:one).goals.create!(title: "Learn Rails", status: "planned")

    assert_no_difference("Resource.count") do
      post goal_resources_path(goal), params: { resource: { title: "", url: "not-a-url" } }
    end
    assert_response :unprocessable_entity
    assert_select ".form-errors li", /can.t be blank/
  end

  test "deletes the signed-in user's own resource" do
    # The old bookmarks_controller_test.rb had this exact coverage for
    # Bookmark; it wasn't rebuilt for Resource (review finding F2).
    goal = users(:one).goals.create!(title: "Learn Rails", status: "planned")
    resource = goal.resources.create!(title: "Rails Guides", url: "https://guides.rubyonrails.org")

    assert_difference("Resource.count", -1) do
      delete resource_path(resource)
    end
    assert_redirected_to goal_path(goal)

    get goal_path(goal)
    assert_no_match "Rails Guides", response.body
  end

  test "rejects an out-of-range resource_type instead of crashing" do
    # Rails enums raise ArgumentError on assignment of a value outside
    # their defined set — a crafted POST (bypassing the <select>, e.g.
    # via curl) with a garbage resource_type must not 500 the app
    # (review finding F3, ticket 006 round 1 — also affects Goal#status).
    goal = users(:one).goals.create!(title: "Learn Rails", status: "planned")

    assert_no_difference("Resource.count") do
      post goal_resources_path(goal), params: { resource: { title: "X", url: "https://example.com", resource_type: "garbage" } }
    end
    assert_response :bad_request
  end

  test "blocks creating a resource under another user's goal with 404" do
    other_goal = users(:two).goals.create!(title: "Not yours", status: "planned")

    assert_no_difference("Resource.count") do
      post goal_resources_path(other_goal), params: { resource: { title: "Sneaky", url: "https://example.com" } }
    end
    assert_response :not_found
  end

  test "blocks destroying another user's resource with 404" do
    other_goal = users(:two).goals.create!(title: "Not yours", status: "planned")
    other_resource = other_goal.resources.create!(title: "Not yours either", url: "https://example.com")

    delete resource_path(other_resource)

    assert_response :not_found
    assert Resource.exists?(other_resource.id), "the other user's resource must not be touched"
  end
end
