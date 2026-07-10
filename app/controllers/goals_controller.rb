# Every lookup here goes through Current.user.goals — the association
# scope itself is the security boundary. An id outside that scope raises
# ActiveRecord::RecordNotFound, which this app renders as a real 404
# (config.action_dispatch.show_exceptions = :rescuable), so a wrong-user
# request looks identical to a nonexistent one — no data leaks either way.
class GoalsController < ApplicationController
  def index
    @goals = Current.user.goals.order(created_at: :desc)
  end

  def show
    @goal = Current.user.goals.find(params[:id])
    @learning_sessions = @goal.learning_sessions.order(date: :desc)
  end

  def new
    @goal = Current.user.goals.build
  end

  def create
    @goal = Current.user.goals.build(goal_params)
    if @goal.save
      redirect_to @goal
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @goal = Current.user.goals.find(params[:id])
  end

  def update
    @goal = Current.user.goals.find(params[:id])
    if @goal.update(goal_params)
      redirect_to @goal
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    Current.user.goals.find(params[:id]).destroy
    redirect_to goals_path
  end

  private

  def goal_params
    params.require(:goal).permit(:title, :description, :status)
  end
end
