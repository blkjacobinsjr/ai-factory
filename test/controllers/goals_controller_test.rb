# Goals are the first records in this app that are genuinely private per
# user. Every test here signs in first — these tests exist to prove a
# user's own data behaves correctly AND (see later tests) that another
# user's data never leaks through.
#
# The goals index is also the homepage (root moved here from the old
# bookmarks page in ticket 006) — the layout-level tests below (tailwind
# link, pipeline strip, anonymous redirect) used to live in
# bookmarks_controller_test.rb and moved here along with root.
require "test_helper"

class GoalsControllerTest < ActionDispatch::IntegrationTest
  # Applies before EVERY test below, regardless of declaration order —
  # the anonymous-visitor test undoes it with sign_out instead of trying
  # to run before this callback fires.
  setup { sign_in_as users(:one) }

  test "anonymous visitor is redirected to sign-in" do
    sign_out
    get root_url
    assert_redirected_to new_session_path
  end

  test "GET / links the tailwind stylesheet exactly once" do
    # Rails 8.1's stylesheet_link_tag :app already auto-includes the
    # compiled Tailwind build — a second, manual tailwind tag in the
    # layout was a duplicate (issue #10), not a second real stylesheet.
    get root_url

    assert_select "link[rel=stylesheet][href*=?]", "tailwind", 1
  end

  test "homepage shows the 5-step pipeline strip above the goals list" do
    get root_url

    assert_select ".pipeline .step", 5
    assert_equal %w[refine plan implement review merge],
                 css_select(".pipeline .step-label").map(&:text)
    assert_operator response.body.index('class="pipeline"'), :<, response.body.index("Goals"),
                    "pipeline strip must come before the goals list"
  end

  test "pipeline strip shows the current factory phase" do
    get root_url

    assert_select ".pipeline .phase-badge", text: FactoryState.phase
  end

  test "pipeline strip is wired to the Stimulus controller" do
    get root_url

    assert_select ".pipeline[data-controller=pipeline]"
    assert_select ".pipeline [data-pipeline-target=step]", 5
    assert_select ".pipeline .step[data-detail]", 5
    assert_select ".pipeline button[data-action*=pipeline]"
  end

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

  test "filters the goals index by status" do
    users(:one).goals.create!(title: "Planned goal", status: "planned")
    users(:one).goals.create!(title: "Active goal", status: "in_progress")

    get goals_path(status: "in_progress")

    assert_match "Active goal", response.body
    assert_no_match "Planned goal", response.body
  end
end
