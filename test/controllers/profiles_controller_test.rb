# The profile route has no :id — there is no URL to edit to see someone
# else's profile. This test proves that structural fact holds in practice:
# signed in as one user, another user's data must never appear on the page.
require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @own_user = users(:one)
    @own_user.create_profile!(name: "Ada Lovelace", cohort: "2026-A", focus_areas: "ruby, rails")

    @other_user = users(:two)
    @other_user.create_profile!(name: "Grace Hopper", cohort: "2026-B", focus_areas: "cobol")

    sign_in_as @own_user
  end

  test "shows only the signed-in user's own profile data" do
    get profile_path

    assert_response :success
    assert_match "Ada Lovelace", response.body
    assert_match "2026-A", response.body
    assert_match "ruby", response.body
    assert_match "rails", response.body
    assert_no_match "Grace Hopper", response.body
  end
end
