# Read-only aggregations over the signed-in user's own data. Every query
# goes through Current.user.goals / Current.user.learning_sessions — same
# scoping boundary as every other controller in this app.
class DashboardController < ApplicationController
  def index
    @goals_by_status = Current.user.goals.group(:status).count
    # tags is a plain comma-separated string (not a normalized tags table —
    # same simplification as Profile#focus_areas), so this groups by the
    # exact stored string, not by individual tag word within a multi-tag
    # session (documented tradeoff, see ticket 008's out-of-scope note).
    @minutes_by_tag = Current.user.learning_sessions.group(:tags).sum(:duration)
    # SQLite-specific date truncation (this app's only DB) — the standard,
    # minimal way to group by week without adding the groupdate gem.
    # %W = week number, Monday-first, confirmed via a direct SQL check.
    @minutes_by_week = Current.user.learning_sessions.group("strftime('%Y-%W', date)").sum(:duration)
  end
end
