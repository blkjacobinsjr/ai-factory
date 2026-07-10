# Learning sessions are logged AGAINST a goal (nested route) but scoped
# through the SAME Current.user boundary as goals — see
# Current.user.goals.find in the controller.
require "test_helper"

class LearningSessionsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "creates a learning session that appears on the goal's page" do
    goal = users(:one).goals.create!(title: "Learn Rails", status: "planned")

    assert_difference("LearningSession.count", 1) do
      post goal_learning_sessions_path(goal), params: {
        learning_session: { date: Date.today, duration: 45, notes: "Read guides", tags: "rails, reading" }
      }
    end
    assert_redirected_to goal_path(goal)

    get goal_path(goal)
    assert_match "Read guides", response.body
  end
end
