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

  test "blocks destroying another user's learning session with 404" do
    other_goal = users(:two).goals.create!(title: "Not yours", status: "planned")
    other_session = other_goal.learning_sessions.create!(date: Date.today, duration: 30)

    delete learning_session_path(other_session)

    assert_response :not_found
    assert LearningSession.exists?(other_session.id), "the other user's session must not be touched"
  end
end
