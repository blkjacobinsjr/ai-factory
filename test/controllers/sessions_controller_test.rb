require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = User.take }

  test "new" do
    get new_session_path
    assert_response :success
  end

  test "create with valid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "password" }

    assert_redirected_to root_path
    assert cookies[:session_id]
  end

  test "create with invalid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "wrong" }

    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
  end

  test "destroy" do
    sign_in_as(User.take)

    delete session_path

    assert_redirected_to new_session_path
    assert_empty cookies[:session_id]
  end

  test "signing out ends the session for the next request too" do
    # The generator's own "destroy" test above stops at the redirect —
    # ticket 004's criterion 3 needs proof the session is actually gone,
    # not just that this one response redirected.
    sign_in_as(User.take)
    delete session_path

    get root_url

    assert_redirected_to new_session_path
  end
end
