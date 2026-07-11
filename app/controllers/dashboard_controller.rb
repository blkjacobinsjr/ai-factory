# Read-only aggregations over the signed-in user's own data. Every query
# goes through Current.user.goals / Current.user.learning_sessions — same
# scoping boundary as every other controller in this app.
class DashboardController < ApplicationController
  def index
    @goals_by_status = Current.user.goals.group(:status).count
  end
end
