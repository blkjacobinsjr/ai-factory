# Mirrors LearningSessionsController's scoping exactly: create is nested
# under a goal (params[:goal_id] scoped via Current.user.goals), destroy is
# a shallow route (no goal_id) scoped via Current.user.resources.
class ResourcesController < ApplicationController
  def create
    @goal = Current.user.goals.find(params[:goal_id])
    @resource = @goal.resources.build(resource_params)
    if @resource.save
      redirect_to @goal
    else
      # Re-render the goal page so the attach form's errors are visible —
      # a bare redirect on failure (the original bug here) silently
      # discards invalid input with no explanation to the user.
      @learning_sessions = @goal.learning_sessions.order(date: :desc)
      @resources = @goal.resources.order(created_at: :desc)
      render "goals/show", status: :unprocessable_entity
    end
  end

  def destroy
    resource = Current.user.resources.find(params[:id])
    goal = resource.goal
    resource.destroy
    redirect_to goal
  end

  private

  def resource_params
    params.require(:resource).permit(:title, :url, :resource_type)
  end
end
