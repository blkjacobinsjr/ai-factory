# The signed-in user's name/cohort/focus-areas — kept apart from User so
# authentication (password, sessions) never mixes with profile display data.
class Profile < ApplicationRecord
  belongs_to :user

  # focus_areas is stored as "ruby,rails" — this is the only place that
  # knows that; callers (the profile view) get a clean array of tags.
  def focus_area_list
    focus_areas.to_s.split(",").map(&:strip).reject(&:empty?)
  end
end
