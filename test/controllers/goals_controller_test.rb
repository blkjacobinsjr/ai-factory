# Goals are the first records in this app that are genuinely private per
# user (bookmarks are shared/global). Every test here signs in first —
# these tests exist to prove a user's own data behaves correctly AND
# (see later tests) that another user's data never leaks through.
require "test_helper"

class GoalsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "creates a goal that appears on the signed-in user's index" do
    assert_difference("Goal.count", 1) do
      post goals_path, params: { goal: { title: "Learn Rails", description: "Ship a real app", status: "planned" } }
    end

    goal = Goal.last
    assert_equal users(:one), goal.user
    assert_redirected_to goal_path(goal)

    get goals_path
    assert_match "Learn Rails", response.body
  end

  test "edits and deletes the signed-in user's own goal" do
    goal = users(:one).goals.create!(title: "Old title", status: "planned")

    patch goal_path(goal), params: { goal: { title: "New title" } }
    assert_equal "New title", goal.reload.title

    assert_difference("Goal.count", -1) do
      delete goal_path(goal)
    end
    get goals_path
    assert_no_match "New title", response.body
  end

  test "blocks show/edit/destroy of another user's goal with 404" do
    other_goal = users(:two).goals.create!(title: "Not yours", status: "planned")

    get goal_path(other_goal)
    assert_response :not_found

    get edit_goal_path(other_goal)
    assert_response :not_found

    delete goal_path(other_goal)
    assert_response :not_found
    assert Goal.exists?(other_goal.id), "the other user's goal must not be touched"
  end
end
