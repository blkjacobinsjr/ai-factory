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
end
