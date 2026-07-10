# Mirrors LearningSessionsController's scoping exactly: create is nested
# under a goal (params[:goal_id] scoped via Current.user.goals), destroy is
# a shallow route (no goal_id) scoped via Current.user.resources.
class ResourcesController < ApplicationController
  def create
    @goal = Current.user.goals.find(params[:goal_id])
    @goal.resources.create(resource_params)
    redirect_to @goal
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
