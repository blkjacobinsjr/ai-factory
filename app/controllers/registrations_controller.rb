# The sign-up flow Rails 8's authentication generator intentionally
# doesn't provide (registration is app-specific by design). Mirrors
# SessionsController's shape: allow anonymous access to new/create, and on
# success reuse the SAME start_new_session_for as sign-in — a new account
# is signed in immediately, not sent to a separate login step.
class RegistrationsController < ApplicationController
  allow_unauthenticated_access
  # Matches SessionsController/PasswordsController's existing throttle —
  # sign-up was the one unthrottled auth entry point (review finding F3).
  rate_limit to: 10, within: 3.minutes, only: :create,
             with: -> { redirect_to sign_up_path, alert: "Try again later." }

  def new
    @user = User.new
  end

  def create
    # form_with model: @user (app/views/registrations/new.html.erb) posts
    # params nested under "user" — a flat params.permit(:email_address,
    # :password) reads the wrong keys and 422s the real form even though a
    # test posting flat params directly would wrongly pass (review F1).
    @user = User.new(params.require(:user).permit(:email_address, :password))
    if @user.save
      start_new_session_for @user
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end
end
