# AiInsightService's real network call is never exercised in this suite
# (no webmock/vcr in this app) — every test here stubs the service's
# public methods instead, per the ticket's own out-of-scope note. A real
# call is exercised once during manual/browser review.
require "test_helper"

class AiInsightsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "generates and persists a summary from the goal's sessions and resources" do
    goal = users(:one).goals.create!(title: "Learn Rails", status: "planned")
    goal.learning_sessions.create!(date: Date.today, duration: 45, notes: "Read guides")
    goal.resources.create!(title: "Rails Guides", url: "https://guides.rubyonrails.org")

    stub_class_method(AiInsightService, :summarize, "You spent 45 minutes reading the guides.") do
      post generate_summary_goal_path(goal)
    end

    assert_redirected_to goal
    assert_equal "You spent 45 minutes reading the guides.", goal.reload.ai_summary

    get goal_path(goal)
    assert_match "You spent 45 minutes reading the guides.", response.body
  end

  test "generates and persists 2-3 next steps as a list" do
    goal = users(:one).goals.create!(title: "Learn Rails", status: "planned")

    stub_class_method(AiInsightService, :next_steps, "Read Action View guide\nBuild a small CRUD app\nWrite tests for it") do
      post suggest_next_steps_goal_path(goal)
    end

    assert_redirected_to goal
    assert_equal 3, goal.reload.ai_next_steps.lines.count

    get goal_path(goal)
    assert_select ".ai-next-steps li", 3
  end

  test "shows a clear error and saves nothing when the AI provider fails" do
    goal = users(:one).goals.create!(title: "Learn Rails", status: "planned")

    raise_error = -> (*) { raise AiInsightService::Error, "could not reach the AI provider: timeout" }
    stub_class_method(AiInsightService, :summarize, raise_error) do
      post generate_summary_goal_path(goal)
    end

    assert_redirected_to goal
    assert_nil goal.reload.ai_summary

    follow_redirect!
    assert_select ".form-errors", /could not reach the AI provider/
  end

  test "blocks AI actions on another user's goal with 404, no AI call made" do
    other_goal = users(:two).goals.create!(title: "Not yours", status: "planned")

    # If the scoping were wrong and this got called at all, raising here
    # fails the test loudly — proving no AI call happens, not just that
    # the eventual response is a 404.
    called_unexpectedly = -> (*) { raise "AI service must not be called for another user's goal" }

    stub_class_method(AiInsightService, :summarize, called_unexpectedly) do
      post generate_summary_goal_path(other_goal)
      assert_response :not_found
    end

    stub_class_method(AiInsightService, :next_steps, called_unexpectedly) do
      post suggest_next_steps_goal_path(other_goal)
      assert_response :not_found
    end
  end
end
