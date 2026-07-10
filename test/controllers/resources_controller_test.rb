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
    assert_match "doc", response.body
  end

  test "rejects a resource with a blank title or a non-http(s) url" do
    goal = users(:one).goals.create!(title: "Learn Rails", status: "planned")

    assert_no_difference("Resource.count") do
      post goal_resources_path(goal), params: { resource: { title: "", url: "not-a-url" } }
    end
    assert_response :unprocessable_entity
    assert_select ".form-errors li", /can.t be blank/
  end
end
