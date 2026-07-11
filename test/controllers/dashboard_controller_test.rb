# Every aggregation here is built as its own instance variable in the
# SAME action, one per criterion — not separate actions, to avoid ticket
# 007's front-loading lapse (a later step's code sitting there unused
# before its own step exists).
require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "shows goal counts per status" do
    users(:one).goals.create!(title: "Planned goal", status: "planned")
    users(:one).goals.create!(title: "Another planned goal", status: "planned")
    users(:one).goals.create!(title: "Active goal", status: "in_progress")

    get dashboard_path

    assert_response :success
    assert_select "td", text: "planned"
    assert_select "td", text: "2"
    assert_select "td", text: "in_progress"
    assert_select "td", text: "1"
  end

  test "shows total hours per tags value" do
    goal = users(:one).goals.create!(title: "Learn Rails", status: "planned")
    goal.learning_sessions.create!(date: Date.today, duration: 60, tags: "rails")
    goal.learning_sessions.create!(date: Date.today, duration: 30, tags: "rails")
    goal.learning_sessions.create!(date: Date.today, duration: 45, tags: "testing")

    get dashboard_path

    assert_select "td", text: "rails"
    assert_select "td", text: "1.5" # 90 minutes = 1.5 hours
    assert_select "td", text: "testing"
    assert_select "td", text: "0.75" # 45 minutes = 0.75 hours
  end

  test "shows total hours per week" do
    goal = users(:one).goals.create!(title: "Learn Rails", status: "planned")
    # Two dates in the same ISO week, one in a different week.
    goal.learning_sessions.create!(date: Date.new(2026, 7, 6), duration: 60)
    goal.learning_sessions.create!(date: Date.new(2026, 7, 8), duration: 60)
    goal.learning_sessions.create!(date: Date.new(2026, 6, 29), duration: 30)

    get dashboard_path

    assert_select "td", text: "2026-27"
    assert_select "td", text: "2.0" # 120 minutes = 2 hours
    assert_select "td", text: "2026-26"
    assert_select "td", text: "0.5" # 30 minutes = 0.5 hours
  end

  test "excludes other users' goals and sessions from every aggregation" do
    other_goal = users(:two).goals.create!(title: "Not yours", status: "done")
    other_goal.learning_sessions.create!(date: Date.today, duration: 999, tags: "not-yours-tag")

    get dashboard_path

    assert_response :success
    assert_no_match "Not yours", response.body
    assert_no_match "not-yours-tag", response.body
    # "done" as a status could theoretically appear if OUR user also had a
    # done goal (they don't, in this test) — assert the count specifically
    # isn't inflated by the other user's row.
    assert_select "td", text: "done", count: 0
  end
end
