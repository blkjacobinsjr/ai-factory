class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Rails enums (Goal#status, Resource#resource_type, …) raise ArgumentError
  # the moment an out-of-range value is ASSIGNED — before any validation
  # even runs — so a crafted request with a bogus enum value (bypassing the
  # <select> a real user sees) 500s instead of failing like normal bad
  # input. One shared rescue here covers every enum in the app, present
  # and future, rather than guarding each controller separately.
  rescue_from ArgumentError do
    head :bad_request
  end
end
