# The sign-up flow Rails 8's authentication generator intentionally
# doesn't provide (registration is app-specific by design). Mirrors
# SessionsController's shape: allow anonymous access to new/create, and on
# success reuse the SAME start_new_session_for as sign-in — a new account
# is signed in immediately, not sent to a separate login step.
class RegistrationsController < ApplicationController
  allow_unauthenticated_access

  def new
    @user = User.new
  end

  def create
    @user = User.new(params.permit(:email_address, :password))
    if @user.save
      start_new_session_for @user
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end
end
