class DietPlanController < ApplicationController
  def show
    @diet_plan = DietPlan.find(params[:id])
  end
end
