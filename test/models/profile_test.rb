# Profile is the "who is this person" data (name, cohort, focus areas)
# separate from the account credentials User holds. Kept as its own model
# so auth concerns (password, sessions) never mix with profile concerns.
require "test_helper"

class ProfileTest < ActiveSupport::TestCase
  test "persists and is accessible via user.profile" do
    user = User.create!(email_address: "profile-test@example.com", password: "password")

    profile = Profile.create!(user: user, name: "Ada", cohort: "2026-A", focus_areas: "ruby,rails")

    assert_equal profile, user.reload.profile
  end
end
