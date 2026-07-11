# Triggers AiInsightService against the signed-in user's own Goal (same
# Current.user.goals scoping as every other controller in this app — an
# id outside that scope 404s before the AI service is ever called).
#
# Only AiInsightService::Error is rescued — update! writing a plain text
# column can't itself fail validation, so an unhandled exception there
# would mean something more seriously wrong than "the AI call failed,"
# which is the one failure mode this ticket's criteria cover.
class AiInsightsController < ApplicationController
  def generate_summary
    goal = Current.user.goals.find(params[:id])
    goal.update!(ai_summary: AiInsightService.summarize(goal))
    redirect_to goal
  rescue AiInsightService::Error => e
    # Raised BEFORE update! runs, so nothing partial/stale gets saved —
    # the user just sees why it didn't work this time.
    redirect_to goal, alert: e.message
  end

  def suggest_next_steps
    goal = Current.user.goals.find(params[:id])
    goal.update!(ai_next_steps: AiInsightService.next_steps(goal))
    redirect_to goal
  rescue AiInsightService::Error => e
    redirect_to goal, alert: e.message
  end
end
