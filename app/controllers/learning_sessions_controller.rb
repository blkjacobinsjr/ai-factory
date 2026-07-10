# Nested under a Goal for create (params[:goal_id] scopes it), but destroy
# is a shallow route (/learning_sessions/:id, no goal_id) — scoped instead
# via Current.user.learning_sessions, the through: :goals association on
# User. Either way, an id outside the current user's goals 404s.
class LearningSessionsController < ApplicationController
  def create
    @goal = Current.user.goals.find(params[:goal_id])
    @goal.learning_sessions.create(learning_session_params)
    redirect_to @goal
  end

  def destroy
    session = Current.user.learning_sessions.find(params[:id])
    goal = session.goal
    session.destroy
    redirect_to goal
  end

  private

  def learning_session_params
    params.require(:learning_session).permit(:date, :duration, :notes, :tags)
  end
end
