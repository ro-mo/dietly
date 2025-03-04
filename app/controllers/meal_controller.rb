class MealController < ApplicationController
  def show
    @meal = Meal.find(params[:id])
  end
end

