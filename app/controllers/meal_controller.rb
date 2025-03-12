class MealController < ApplicationController
  def show
    @meal = Meal.find(params[:id])
  end

  def create
    @meal = Meal.new(meal_params)
    if @meal.save
      redirect_to @meal, notice: "Meal created successfully"
    end
  end
  
end

