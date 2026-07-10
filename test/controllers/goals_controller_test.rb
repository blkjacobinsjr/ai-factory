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
end
