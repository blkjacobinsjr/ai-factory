# Shows the SIGNED-IN user's own profile. There is no :id param on this
# route (see config/routes.rb) — Current.user is the only user this
# controller can ever look up, so "show someone else's profile" isn't a
# permission check we might get wrong, it's a request that can't be made.
class ProfilesController < ApplicationController
  def show
    @profile = Current.user.profile
  end
end
