require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "is invalid with a duplicate email address" do
    # Without this, a duplicate signup hits the DB's unique index directly
    # and raises ActiveRecord::RecordNotUnique — a 500, not a normal
    # "email taken" form error (review finding F2, ticket 004 round 1).
    User.create!(email_address: "taken@example.com", password: "password")
    dupe = User.new(email_address: "taken@example.com", password: "password")

    assert_not dupe.valid?
    assert dupe.errors[:email_address].any?
  end
end
