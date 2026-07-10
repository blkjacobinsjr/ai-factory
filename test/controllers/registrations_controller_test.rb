# Rails 8's authentication generator deliberately ships NO sign-up flow
# (registration is app-specific, by design) — this is the one we add.
require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "sign-up creates a user, signs them in, redirects home" do
    # Nested under user: — this is the shape form_with model: @user actually
    # posts. A flat {email_address:, password:} shape (the previous version
    # of this test) passes even when the real form 422s, because it doesn't
    # match what a browser sends (review finding F1, ticket 004 round 1).
    assert_difference("User.count", 1) do
      post sign_up_path, params: { user: { email_address: "new@example.com", password: "password" } }
    end
    assert_redirected_to root_path

    # Redirect alone doesn't prove they're signed in — a second request
    # only succeeds (rather than bouncing to sign-in) if the session took.
    get root_url
    assert_response :success
  end

  test "rejects a too-short password" do
    # has_secure_password only caps length at bcrypt's 72-char limit — a
    # trivially guessable 3-char password is otherwise accepted as-is
    # (review finding F4, ticket 004 round 1).
    assert_no_difference("User.count") do
      post sign_up_path, params: { user: { email_address: "short@example.com", password: "abc" } }
    end
    assert_response :unprocessable_entity
  end
end
