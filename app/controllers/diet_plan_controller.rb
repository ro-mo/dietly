class DietPlanController < ApplicationController
  def show
    @diet_plan = DietPlan.find(params[:id])
  end

  def create
    @diet_plan = DietPlan.new(diet_plan_params)
    if @diet_plan.save
      redirect_to @diet_plan, notice: "Diet plan created successfully"
    end
  end

end
